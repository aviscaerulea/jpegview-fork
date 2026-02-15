#include "stdafx.h"
#include "SVGWrapper.h"
#include "MaxImageDef.h"

#ifndef WINXP

#include <shlobj.h>
#include <lunasvg.h>
#include <zlib.h>

// SVGZ (gzip 圧縮 SVG) を展開
unsigned char* SvgReader::DecompressSvgz(const void* data, int size, unsigned long& outSize) {
	if (size < 2) return NULL;

	// gzip マジックバイト判定 (0x1F 0x8B)
	const unsigned char* bytes = (const unsigned char*)data;
	if (bytes[0] != 0x1F || bytes[1] != 0x8B) {
		// 通常の SVG（非圧縮）
		return NULL;
	}

	// 展開先バッファ確保（入力の 20 倍を初期サイズと仮定）
	unsigned long bufferSize = size * 20;
	unsigned char* buffer = new unsigned char[bufferSize];

	z_stream stream = {};
	stream.next_in = (Bytef*)data;
	stream.avail_in = size;
	stream.next_out = buffer;
	stream.avail_out = bufferSize;

	// inflateInit2 で gzip 形式を指定 (windowBits = 15 + 16)
	int ret = inflateInit2(&stream, 15 + 16);
	if (ret != Z_OK) {
		delete[] buffer;
		return NULL;
	}

	// 展開実行（必要に応じてバッファを拡張）
	while (true) {
		ret = inflate(&stream, Z_NO_FLUSH);
		if (ret == Z_STREAM_END) {
			// 展開完了
			outSize = stream.total_out;
			inflateEnd(&stream);
			return buffer;
		}
		if (ret != Z_OK && ret != Z_BUF_ERROR) {
			// エラー
			inflateEnd(&stream);
			delete[] buffer;
			return NULL;
		}

		// バッファ不足の場合は拡張
		if (stream.avail_out == 0) {
			unsigned long newSize = bufferSize * 2;
			unsigned char* newBuffer = new unsigned char[newSize];
			memcpy(newBuffer, buffer, bufferSize);
			delete[] buffer;
			buffer = newBuffer;
			stream.next_out = buffer + bufferSize;
			stream.avail_out = bufferSize;
			bufferSize = newSize;
		}
	}
}

// 画面サイズに基づく最適レンダリングサイズを計算
void SvgReader::CalculateFitSize(float svgWidth, float svgHeight,
	int& outWidth, int& outHeight) {
	// プライマリモニタの画面解像度を取得
	int screenWidth = ::GetSystemMetrics(SM_CXSCREEN);
	int screenHeight = ::GetSystemMetrics(SM_CYSCREEN);

	// アスペクト比を維持して画面に収まるサイズを計算
	float scaleX = (float)screenWidth / svgWidth;
	float scaleY = (float)screenHeight / svgHeight;
	float scale = min(scaleX, scaleY);

	outWidth = (int)(svgWidth * scale);
	outHeight = (int)(svgHeight * scale);

	// 次元上限チェック
	if (outWidth > MAX_IMAGE_DIMENSION) {
		float ratio = (float)MAX_IMAGE_DIMENSION / outWidth;
		outWidth = MAX_IMAGE_DIMENSION;
		outHeight = (int)(outHeight * ratio);
	}
	if (outHeight > MAX_IMAGE_DIMENSION) {
		float ratio = (float)MAX_IMAGE_DIMENSION / outHeight;
		outHeight = MAX_IMAGE_DIMENSION;
		outWidth = (int)(outWidth * ratio);
	}
}

void* SvgReader::ReadImage(int& width, int& height, int& bpp,
	bool& outOfMemory, const void* buffer, int sizebytes)
{
	// フォールバック用日本語フォントの初期化（初回のみ）
	static bool fontsInitialized = false;
	if (!fontsInitialized) {
		fontsInitialized = true;

		// システムフォントディレクトリの動的取得
		char fontsDir[MAX_PATH] = {};
		if (FAILED(::SHGetFolderPathA(NULL, CSIDL_FONTS, NULL, 0, fontsDir))) {
			// フォールバック: 標準パスを使用
			strcpy_s(fontsDir, "C:\\Windows\\Fonts");
		}

		// Yu Gothic → Meiryo → MS Gothic の優先順
		// Yu Gothic, MS Gothic は Win11 コアフォント（全エディション同梱）
		// Meiryo は Supplemental だが日本語環境では通常インストール済み
		static const char* fontFiles[] = {
			"YuGothR.ttc",
			"meiryo.ttc",
			"msgothic.ttc",
		};
		for (const char* fontFile : fontFiles) {
			char fontPath[MAX_PATH];
			sprintf_s(fontPath, "%s\\%s", fontsDir, fontFile);
			if (::GetFileAttributesA(fontPath) != INVALID_FILE_ATTRIBUTES) {
				// generic family 名で登録し、Arial 等へのフォールバックを防ぐ
				lunasvg_add_font_face_from_file("sans-serif", false, false, fontPath);
				lunasvg_add_font_face_from_file("serif", false, false, fontPath);
				lunasvg_add_font_face_from_file("monospace", false, false, fontPath);
				// font-family 未指定時のフォールバック
				lunasvg_add_font_face_from_file("", false, false, fontPath);
				break;
			}
		}
	}

	outOfMemory = false;
	width = height = 0;
	bpp = 4;  // BGRA

	if (buffer == NULL || sizebytes <= 0 || sizebytes > MAX_SVG_FILE_SIZE) {
		return NULL;
	}

	const char* svgData = (const char*)buffer;
	int svgSize = sizebytes;
	unsigned char* decompressedData = NULL;

	// SVGZ 判定と展開
	unsigned long decompressedSize = 0;
	decompressedData = DecompressSvgz(buffer, sizebytes, decompressedSize);
	if (decompressedData != NULL) {
		svgData = (const char*)decompressedData;
		svgSize = decompressedSize;
	}

	// SVG パース
	auto document = lunasvg::Document::loadFromData(svgData, svgSize);
	if (decompressedData != NULL) {
		delete[] decompressedData;
	}

	if (document == nullptr) {
		return NULL;
	}

	// SVG サイズ取得
	float svgWidth = (float)document->width();
	float svgHeight = (float)document->height();

	// サイズが未定義の場合はバウンディングボックスから取得
	if (svgWidth <= 0 || svgHeight <= 0) {
		auto box = document->boundingBox();
		svgWidth = box.w;
		svgHeight = box.h;
	}

	if (svgWidth <= 0 || svgHeight <= 0) {
		return NULL;
	}

	// 画面フィットサイズ計算
	CalculateFitSize(svgWidth, svgHeight, width, height);

	// ピクセル上限チェック
	if (abs((double)width * height) > MAX_IMAGE_PIXELS) {
		outOfMemory = true;
		return NULL;
	}

	// ビットマップレンダリング（白背景: 0xFFFFFFFF）
	auto bitmap = document->renderToBitmap(width, height, 0xFFFFFFFF);
	if (bitmap.isNull()) {
		outOfMemory = true;
		return NULL;
	}

	// ピクセルデータ取得（lunasvg は ARGB 形式で返す）
	const uint32_t* argbData = (const uint32_t*)bitmap.data();
	int pixelCount = width * height;

	// BGRA 形式にコピー + バイトスワップ
	unsigned char* pPixelData = new unsigned char[pixelCount * 4];
	for (int i = 0; i < pixelCount; i++) {
		uint32_t pixel = argbData[i];
		// ARGB → BGRA (白背景なので alpha は無視してよい)
		pPixelData[i * 4 + 0] = (pixel >> 0) & 0xFF;  // B
		pPixelData[i * 4 + 1] = (pixel >> 8) & 0xFF;  // G
		pPixelData[i * 4 + 2] = (pixel >> 16) & 0xFF; // R
		pPixelData[i * 4 + 3] = (pixel >> 24) & 0xFF; // A
	}

	return pPixelData;
}

#endif  // !WINXP
