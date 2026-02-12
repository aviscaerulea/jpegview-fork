#pragma once

#include <windows.h>

// PDFium ベースの PDF レンダリングラッパー（表紙のみ対応）
class PdfReader
{
public:
	// PDF 表紙（1 ページ目）を BGRA ピクセルデータとしてレンダリング
	// 戻り値: BGRA ピクセルデータ (new unsigned char[])、失敗時 NULL
	static void* ReadImage(int& width, int& height, int& bpp,
		bool& outOfMemory, HANDLE hFile, unsigned long fileSize);

private:
	// 画面サイズに基づく最適 DPI を計算（速度優先: 上限 150 DPI）
	static double CalculateOptimalDPI(double pageWidthPt, double pageHeightPt);
};
