#include "stdafx.h"
#include "PDFWrapper.h"
#include "MaxImageDef.h"

#ifndef WINXP

#include <fpdfview.h>

// 前方宣言
static int ReadBlockFromHandle(void* param, unsigned long position,
	unsigned char* pBuf, unsigned long size);

// PDF ドキュメントキャッシュ（最後の 1 ドキュメントのみ保持）
class CPdfDocumentCache {
public:
	static CPdfDocumentCache& Instance();
	FPDF_DOCUMENT GetDocument(HANDLE hFile, unsigned long fileSize);
	void ClearAll();

private:
	CPdfDocumentCache();
	~CPdfDocumentCache();
	static CPdfDocumentCache* sm_instance;

	FPDF_DOCUMENT m_cachedDocument;
	HANDLE m_cachedHandle;
	CRITICAL_SECTION m_cs;
};

CPdfDocumentCache* CPdfDocumentCache::sm_instance = NULL;

CPdfDocumentCache& CPdfDocumentCache::Instance() {
	if (sm_instance == NULL) {
		sm_instance = new CPdfDocumentCache();
	}
	return *sm_instance;
}

CPdfDocumentCache::CPdfDocumentCache() {
	m_cachedDocument = NULL;
	m_cachedHandle = NULL;
	::InitializeCriticalSection(&m_cs);
}

CPdfDocumentCache::~CPdfDocumentCache() {
	ClearAll();
	::DeleteCriticalSection(&m_cs);
}

FPDF_DOCUMENT CPdfDocumentCache::GetDocument(HANDLE hFile, unsigned long fileSize) {
	::EnterCriticalSection(&m_cs);

	// キャッシュヒットチェック（ハンドルで判定）
	if (m_cachedDocument != NULL && m_cachedHandle == hFile) {
		::LeaveCriticalSection(&m_cs);
		return m_cachedDocument;
	}

	// キャッシュミス: 既存を破棄して新規ロード
	if (m_cachedDocument != NULL) {
		FPDF_CloseDocument(m_cachedDocument);
		m_cachedDocument = NULL;
	}

	FPDF_FILEACCESS fileAccess;
	fileAccess.m_FileLen = fileSize;
	fileAccess.m_GetBlock = ReadBlockFromHandle;
	fileAccess.m_Param = hFile;

	m_cachedDocument = FPDF_LoadCustomDocument(&fileAccess, NULL);
	m_cachedHandle = hFile;

	::LeaveCriticalSection(&m_cs);
	return m_cachedDocument;
}

void CPdfDocumentCache::ClearAll() {
	::EnterCriticalSection(&m_cs);
	if (m_cachedDocument != NULL) {
		FPDF_CloseDocument(m_cachedDocument);
		m_cachedDocument = NULL;
		m_cachedHandle = NULL;
	}
	::LeaveCriticalSection(&m_cs);
}

// FPDF_FILEACCESS コールバック: HANDLE から指定位置のデータを読み込む
static int ReadBlockFromHandle(void* param, unsigned long position,
	unsigned char* pBuf, unsigned long size) {
	HANDLE hFile = (HANDLE)param;
	DWORD bytesRead = 0;
	LARGE_INTEGER li;
	li.QuadPart = position;
	if (!::SetFilePointerEx(hFile, li, NULL, FILE_BEGIN)) return 0;
	if (!::ReadFile(hFile, pBuf, size, &bytesRead, NULL)) return 0;
	return (bytesRead == size) ? 1 : 0;
}

// 画面サイズに基づく最適 DPI を計算（画面にフィットする DPI）
double PdfReader::CalculateOptimalDPI(double pageWidthPt, double pageHeightPt) {
	// PDF のページサイズは points 単位 (1 point = 1/72 inch)
	double pageWidthInch = pageWidthPt / 72.0;
	double pageHeightInch = pageHeightPt / 72.0;

	// プライマリモニタの画面解像度を取得
	int screenWidth = ::GetSystemMetrics(SM_CXSCREEN);
	int screenHeight = ::GetSystemMetrics(SM_CYSCREEN);

	// ページ全体が画面に収まる DPI を計算
	double dpiX = screenWidth / pageWidthInch;
	double dpiY = screenHeight / pageHeightInch;
	double dpi = min(dpiX, dpiY);

	// 下限 72 DPI（上限なし: MAX_IMAGE_PIXELS で安全を担保）
	dpi = max(72.0, dpi);
	return dpi;
}

void* PdfReader::ReadImage(int& width, int& height, int& bpp,
	bool& outOfMemory, HANDLE hFile, unsigned long fileSize)
{
	outOfMemory = false;
	width = height = 0;
	bpp = 4;  // BGRA

	unsigned char* pPixelData = NULL;

	// PDFium 初期化（一度だけ）
	static bool initialized = false;
	if (!initialized) {
		FPDF_InitLibrary();
		initialized = true;
	}

	// ドキュメントオープン（キャッシュから取得）
	FPDF_DOCUMENT doc = CPdfDocumentCache::Instance().GetDocument(hFile, fileSize);
	if (doc == NULL) {
		return NULL;
	}

	// ページ数取得（表紙のみ対応だが取得はする）
	int pageCount = FPDF_GetPageCount(doc);
	if (pageCount < 1) {
		// キャッシュが管理するためクローズしない
		return NULL;
	}

	// ページ 0（表紙）をロード
	FPDF_PAGE page = FPDF_LoadPage(doc, 0);
	if (page == NULL) {
		// キャッシュが管理するためクローズしない
		return NULL;
	}

	// ページサイズ取得（points 単位）
	double pageWidthPt = FPDF_GetPageWidth(page);
	double pageHeightPt = FPDF_GetPageHeight(page);

	// 最適 DPI 計算 → ピクセルサイズ決定
	double dpi = CalculateOptimalDPI(pageWidthPt, pageHeightPt);
	width = (int)((pageWidthPt / 72.0) * dpi);
	height = (int)((pageHeightPt / 72.0) * dpi);

	// ピクセル上限チェック
	if (width > MAX_IMAGE_DIMENSION || height > MAX_IMAGE_DIMENSION) {
		FPDF_ClosePage(page);
		// キャッシュが管理するためクローズしない
		return NULL;
	}
	if (abs((double)width * height) > MAX_IMAGE_PIXELS) {
		outOfMemory = true;
		FPDF_ClosePage(page);
		// キャッシュが管理するためクローズしない
		return NULL;
	}

	// ビットマップ作成
	FPDF_BITMAP bitmap = FPDFBitmap_Create(width, height, 0);  // 0 = BGRA
	if (bitmap == NULL) {
		outOfMemory = true;
		FPDF_ClosePage(page);
		// キャッシュが管理するためクローズしない
		return NULL;
	}

	// 白背景填充
	FPDFBitmap_FillRect(bitmap, 0, 0, width, height, 0xFFFFFFFF);

	// レンダリング（品質優先: AA + LCD テキスト最適化）
	int flags = FPDF_ANNOT | FPDF_LCD_TEXT;
	FPDF_RenderPageBitmap(bitmap, page, 0, 0, width, height, 0, flags);

	// ピクセルデータ取得
	void* buffer_ptr = FPDFBitmap_GetBuffer(bitmap);
	int stride = FPDFBitmap_GetStride(bitmap);

	if (buffer_ptr == NULL || stride < width * bpp) {
		FPDFBitmap_Destroy(bitmap);
		FPDF_ClosePage(page);
		// キャッシュが管理するためクローズしない
		return NULL;
	}

	// ピクセルデータをコピー
	int size = width * bpp * height;
	pPixelData = new(std::nothrow) unsigned char[size];
	if (pPixelData == NULL) {
		outOfMemory = true;
		FPDFBitmap_Destroy(bitmap);
		FPDF_ClosePage(page);
		// キャッシュが管理するためクローズしない
		return NULL;
	}

	// PDFium の BGRA は JPEGView と同じフォーマット
	// stride が width*bpp より大きい場合は行ごとにコピー
	for (int y = 0; y < height; y++) {
		memcpy(pPixelData + y * width * bpp,
		       (unsigned char*)buffer_ptr + y * stride,
		       width * bpp);
	}

	// リソース解放（ドキュメントはキャッシュが管理）
	FPDFBitmap_Destroy(bitmap);
	FPDF_ClosePage(page);
	// FPDF_CloseDocument(doc); ← キャッシュに残すため削除

	return (void*)pPixelData;
}

#endif // WINXP
