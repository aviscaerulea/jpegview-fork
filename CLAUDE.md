# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## フォーク元からの変更点

フォーク元: https://github.com/sylikc/jpegview

| コミット | 内容 |
|---|---|
| `c5df10f` | VS2026 (PlatformToolset v145) ビルド対応 |
| `7ab814f` | HEIC 読み込み失敗時に WIC フォールバック追加（libheif 失敗→WIC 再試行） |
| `1747389` | libheif v1.19.8、libavif v1.3.0、dav1d v1.5.1、libde265 v1.0.16 に更新 |
| `c223b7b` | Release\|x64 で AVX2 命令セット有効化（AMD Ryzen 7 9700X 向け最適化） |
| `42d271b` | VS2017 互換ソリューション・プロジェクトファイルを削除 |
| `7a4388a` | .gitignore に CLAUDE.md と UpgradeLog.htm を追加 |
| `90b4a75` | パフォーマンス最適化: スレッドプール上限 16 コア化、AlphaBlendBackground 整数演算化、AVX2 ISA 不整合修正 |
| `6c5b2a7` | 物理コア数検出を CPUID から Windows API（GetLogicalProcessorInformation）に変更（AMD Ryzen 対応） |
| `f6ed9c2` | INI・ドキュメントのコア数記述を修正 |
| `f6ce1a8` | バージョン表記を fork 版に変更、Copyright に 2026 nikai を追加 |
| `abc0fc1` | INI ファイルのコメントを日本語化 |
| `35bc05d` | INI コメントの日本語化改善、デフォルト値変更（IniEditor→system、NavigateWithMouseWheel→true） |
| `c97922f` | サードパーティライブラリ更新: libjpeg-turbo 3.1.3, libpng 1.6.54 (APNG パッチ対応), zlib 1.3.1.2, libwebp 1.6.0, libjxl 0.11.1, libheif 1.21.2, dav1d 1.5.3, LibRaw 0.22.0, lcms2 2.18 |
| `5715140` | パフォーマンス最適化: スレッド数拡大（16→64）、AVIF デコーダ最適化、mimalloc 統合 |
| `17377eb` | PDF 表紙プレビュー機能追加（PDFium ベース）: スムージング有効、DPI 上限撤廃、FPDF_LoadCustomDocument によるファイルベース読み込み、post-build 自動コピー整備 |
| `18800bb` | PDF プレビュー時の Enter キー操作追加: OS 関連付けアプリで開く機能（ShellExecute）|
| `fb53694` | PDF プレビュー時のヒントテキスト表示追加: 画面右下に Enter キーの操作ガイドを表示（ローカライズ対応）|
| `d2da9ca` | HEIF デコーダのスレッド並列化追加: libheif の set_max_decoding_threads API で INI 設定の CPUCoresUsed を使用 |
| `86f89af` | CPU コア数検出を論理コア数（ハイパースレッディング含む）に変更: ProcessorMask ビットカウントで論理プロセッサ数を自動検出 |

### サードパーティライブラリ バージョン比較

| ライブラリ | フォーク元 | 現在 | 主な変更内容 |
|---|---|---|---|
| **libjpeg-turbo** | 2.1.91 | **3.1.3** | メジャーバージョンアップ、パフォーマンス改善 |
| **libpng-apng** | 1.6.40 | **1.6.54** | セキュリティ修正（CVE-2026-22695, CVE-2026-22801） |
| **zlib** | 1.3 | **1.3.1.2** | マイナー更新 |
| **libwebp** | 1.3.2 | **1.6.0** | AVX2/SSE2 最適化追加 |
| **libjxl** | 0.9-snapshot | **0.11.1** | 正式版へ移行、セキュリティ修正 |
| **libheif** | 1.19.8 | **1.21.2** | 機能追加、安定性向上 |
| **libde265** | 1.0.16 | 1.0.16 | 変更なし（最新） |
| **libavif** | 1.3.0 | 1.3.0 | 変更なし（最新） |
| **dav1d** | 1.5.1 | **1.5.3** | 小更新 |
| **LibRaw** | 0.21.1 | **0.22.0** | DNG 1.7 対応追加 |
| **lcms2** | 2.15 | **2.18** | セキュリティ修正含む |
| **PDFium** | - | **（プリビルト）** | Chromium プロジェクトの PDF レンダリングライブラリ。MSVC ランタイム不要 |

## ビルド

- **IDE**: Visual Studio 2026 (PlatformToolset v145)
- **ソリューション**: `src/JPEGView.sln`
- **ビルド構成**: Release|x64（当 PC 向け）
- **C++ 標準**: C++17
- **CRT リンケージ**: `/MT`（静的リンク）、プリビルト DLL は `/MD`（動的リンク）
- **命令セット**: Release|x64 で `/arch:AVX2` 有効

サードパーティライブラリの再ビルドが必要な場合は `extras/scripts/build-*.bat` を使用する。NASM、CMake、Python、meson、ninja が必要。

### mimalloc 統合

JPEGView は mimalloc メモリアロケータを使用してメモリ割り当てを最適化している。

#### mimalloc のビルド手順

1. **リポジトリのクローン**
   ```bash
   cd D:\project-tmp
   git clone https://github.com/microsoft/mimalloc.git
   cd mimalloc
   ```

2. **CMakeSettings.json の編集**

   `CMakeSettings.json` に以下の x64-Release 構成を追加:
   ```json
   {
     "name": "x64-Release",
     "generator": "Ninja",
     "configurationType": "Release",
     "inheritEnvironments": ["msvc_x64_x64"],
     "buildRoot": "${projectDir}\\out\\build\\${name}",
     "installRoot": "${projectDir}\\out\\install\\${name}",
     "cmakeCommandArgs": "-DMI_OVERRIDE=ON -DMI_BUILD_SHARED=OFF -DMI_BUILD_TESTS=OFF -DMI_BUILD_OBJECT=OFF -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded",
     "buildCommandArgs": "",
     "ctestCommandArgs": ""
   }
   ```

   重要なオプション:
   - `MI_OVERRIDE=ON`: malloc/free/new/delete を override
   - `MI_BUILD_SHARED=OFF`: 静的ライブラリとしてビルド
   - `CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded`: `/MT` で静的 CRT リンク

3. **Visual Studio 2026 でビルド**

   VS2026 で `mimalloc` フォルダを開き、x64-Release 構成を選択してビルド。

   出力: `out/build/x64-Release/mimalloc.lib` (約 811KB)

4. **ライブラリのコピー**
   ```bash
   cp D:/project-tmp/mimalloc/out/build/x64-Release/mimalloc.lib \
      D:/project-tmp/jpegview/src/JPEGView/bin/x64/Release/
   ```

#### JPEGView への統合（完了済み）

`src/JPEGView/JPEGView.vcxproj` の Release|x64 構成に以下が追加済み:

- **AdditionalDependencies**: `mimalloc.lib;...`（先頭に追加）
- **AdditionalOptions**: `/INCLUDE:mi_version`（override 機能を有効化）

リンカーは `bin\x64\$(Configuration)` ディレクトリから mimalloc.lib を検索する。

## アーキテクチャ

### プロジェクト構成

| プロジェクト | 出力 | 役割 |
|---|---|---|
| JPEGView | EXE | メインアプリケーション（画像ビューア） |
| WICLoader | DLL (delay-load) | Windows Imaging Component 経由のフォールバックデコーダ |

### 画像読み込みパイプライン

```
ユーザがファイルを開く
  → FileList（ディレクトリ列挙）
  → JPEGProvider（キャッシュ管理 + 先読み）
  → ImageLoadThread（非同期ワーカースレッド）
  → GetImageFormat()：マジックバイトで形式判定
  → ProcessRead*Request()：形式別デコード関数にディスパッチ
  → CJPEGImage 生成（生ピクセル + EXIF メタデータ）
  → WM_IMAGE_LOAD_COMPLETED → MainDlg に通知
  → GetDIB()：表示時にオンデマンドで画像処理（SIMD 最適化）
```

### 形式別デコーダ（Format Wrappers）

各形式は専用ラッパーで分離されている。プリビルト DLL は delay-load で必要時のみロードされる。

| ラッパー | ライブラリ | 対応形式 | delay-load |
|---|---|---|---|
| TJPEGWrapper | libjpeg-turbo | JPEG | No（静的リンク） |
| PNGWrapper | libpng-apng | PNG, APNG | No（静的リンク） |
| WEBPWrapper | libwebp | WebP | No（静的リンク） |
| JXLWrapper | libjxl | JPEG XL | Yes |
| HEIFWrapper | libheif + libde265 | HEIF/HEIC | Yes |
| AVIFWrapper | libavif + dav1d | AVIF | Yes |
| RAWWrapper | LibRaw | Camera RAW | Yes |
| PdfReader | PDFium | PDF（表紙のみ） | Yes |
| PsdReader | 独自実装 | PSD/PSB | No |
| ReaderBMP/TGA | 独自実装 | BMP, TGA | No |

### フォールバックチェーン

デコード失敗時のフォールバック先:

- **HEIF**: libheif → **WIC**（`ProcessReadWICRequest`）
- **AVIF**: libavif → libheif → WIC
- **JPEG**: TurboJpeg → GDI+
- **BMP**: CReaderBMP → GDI+
- **その他**: GDI+

### 主要コンポーネント

| ファイル | 役割 |
|---|---|
| `JPEGView.cpp` | エントリポイント、コマンドライン解析、単一インスタンス制御 |
| `MainDlg.cpp/h` | メインウィンドウ（WTL ベース）、メッセージルーティング |
| `JPEGProvider.cpp/h` | 画像キャッシュ（LRU）と非同期読み込みオーケストレーション |
| `ImageLoadThread.cpp/h` | 非同期画像読み込みスレッド、形式判定とディスパッチ |
| `JPEGImage.cpp/h` | デコード済み画像の中核クラス（ピクセルデータ + メタデータ） |
| `BasicProcessing.cpp/h` | SIMD 最適化ピクセル処理（SSE2/AVX2） |
| `SettingsProvider.cpp/h` | INI ファイル設定管理 |
| `FileList.cpp/h` | ディレクトリファイル列挙・ソート |

### UI フレームワーク

Windows Template Library (WTL) ベース。`Panel` / `PanelMgr` による UI パネル管理システムで、画像処理・回転・クロップ・傾き補正等のパネルを制御する。

### スレッドモデル

- `ImageLoadThread`（`CWorkThread` 派生）で非同期画像読み込み
- `ProcessingThreadPool` で物理コア数分の並列画像処理（上限 64、INI で設定可能）
- AVIF デコーダのスレッド数も INI 設定値を使用（`CPUCoresUsed`）
- HEIF デコーダのスレッド数も INI 設定値を使用（`CPUCoresUsed`）
- 先読みバッファリング（前後の画像をプリロード）

### パフォーマンス最適化

JPEGView の高速表示は以下 6 層の最適化技術の組み合わせで実現されている。

#### 1. SIMD 最適化（SSE2/AVX2）

**対象ファイル**: `BasicProcessing.cpp`, `ApplyFilterAVX.cpp`

- **畳み込みフィルタ**: SSE2 で 8 ピクセル、AVX2 で 16 ピクセルを同時処理
- **固定小数点演算**: 14bit 精度の整数演算で浮動小数点を回避
- **32×32 ブロック回転**: キャッシュヒット率を最大化するブロック単位処理
- **リサイズ + 90 度回転**: X/Y 両方向を同じ Y 方向ループで処理し SIMD を最大活用

高品質リサンプリング (`SampleDown_HQ_SIMD`) は以下の 4 ステップ:
1. RGB DIB → `CXMMImage` (チャネル分離 + 16bit int 変換)
2. Y 方向フィルタリング (`ApplyFilter_AVX` で 16 ピクセル並列)
3. 90 度回転 (`Rotate()` ブロック単位)
4. X 方向フィルタリング (= 回転後の Y 方向) + 回転して DIB に戻す

#### 2. マルチスレッド並列処理

**対象ファイル**: `ProcessingThreadPool.cpp`, `AVIFWrapper.cpp`

- **ストリップ分割**: 画像を水平ストリップに分割し、物理コア数 - 1 のワーカースレッド + 呼び出し元スレッドで並列処理
- **スレッド数上限**: INI 設定 `CPUCoresUsed` で最大 64 まで設定可能（デフォルト: 自動検出された物理コア数）
- **AVIF デコーダ並列化**: libavif/dav1d のデコードスレッド数も INI 設定値を使用（従来はハードコード 256）
- **最小ピクセル閾値**: 10 万ピクセル未満または高さ 12 以下はシングルスレッド（オーバーヘッド回避）
- **キャッシュ最適化**: ストリップあたり最大 10 万ピクセルに制限し、L2/L3 キャッシュに収まるサイズを維持
- **アラインメント**: AVX2 は 16 ピクセル境界、SSE は 8 ピクセル境界でストリップ高を調整

並列化対象: HQ リサイズ、LDC、ガウスフィルタ、アンシャープマスク、HQ 回転、台形補正、AVIF デコード

#### 3. 先読みバッファリング

**対象ファイル**: `JPEGProvider.cpp`

- **方向制御**: FORWARD（次の画像）/BACKWARD（前の画像）/TOGGLE（2 画像間切り替え）で先読み方向を制御
- **バンドル先読み**: `StartNewRequestBundle()` で次/前の複数画像を一括で非同期ロード開始
- **事前処理**: 先読みスレッド上でデコードだけでなくリサイズ+画像処理まで実行し、表示用 DIB を準備完了状態にする
- **方向変更検出**: 閲覧方向が変わった場合は誤った先読みを即座に破棄し再読み込み

#### 4. 非同期画像読み込み

**対象ファイル**: `ImageLoadThread.cpp`

- **非同期キュー**: `ProcessAsync()` でリクエストを非同期キューに投入、ワーカースレッドで処理
- **マジックバイト判定**: 最初の 16 バイトで画像フォーマットを判定（拡張子に依存しない）
- **完了通知**: `WM_IMAGE_LOAD_COMPLETED` メッセージポストまたは `WaitForSingleObject` でブロック待機

#### 5. LRU キャッシュ

**対象ファイル**: `JPEGProvider.cpp`

- **タイムスタンプ管理**: 各画像アクセスごとにタイムスタンプを付与
- **LRU 除去**: `RemoveUnusedImages()` でタイムスタンプ最古の未使用画像から除去
- **バッファ数管理**: 先読み用に 1 バッファ分は常に空ける
- **OOM 対策**: メモリ不足時は `FreeAllPossibleMemory()` で全キャッシュを解放して再試行

#### 6. GetDIB() オンデマンド処理

**対象ファイル**: `JPEGImage.cpp`

- **2 段階キャッシュ**: `m_pDIBPixels`（リサンプリング済み）と `m_pDIBPixelsLUTProcessed`（LUT 適用済み）
- **パラメータ変更検出**: 幾何パラメータ（サイズ、オフセット、回転）と画像処理パラメータ（シャープネス等）の変更を検出
- **LUT のみ再適用**: コントラスト/ガンマ/彩度のみ変更された場合は LUT テーブル参照のみ再適用（リサンプリングの数十倍高速）
- **パンニング最適化**: スクロール時は既存 DIB の再利用可能部分をコピーし、新規表示領域のみリサンプリング

**処理の優先順位**:
1. キャッシュヒット → 即返却
2. パンのみ → `ResampleWithPan()` で差分リサンプリング
3. LUT のみ変更 → `ApplyCorrectionLUTandLDC()` のみ再適用
4. 全て無効化 → `Resample()` でフルリサンプリング (SIMD+並列処理)

#### 最適化の連携

これら 6 層の最適化が連携することで、大画像でもスムーズな表示切り替えとリアルタイムのパン/ズーム/色調調整を実現している。特に先読み+非同期処理+事前 GetDIB により、次の画像に切り替えた瞬間に既にリサイズ済み DIB が準備完了しているという点が高速表示の核心だ。

さらに、**mimalloc メモリアロケータ**の統合により、頻繁なメモリ割り当て・解放（画像バッファ、SIMD 処理用一時バッファ等）のオーバーヘッドが削減され、マルチスレッド環境でのメモリアロケーション競合も最小化されている。

## サードパーティライブラリ

プリビルト DLL は `src/JPEGView/lib*` ディレクトリに格納。ソースは `extras/third_party/` に git submodule として管理。

ビルドスクリプトは `extras/scripts/build-*.bat`（要: NASM, CMake, Python, meson, ninja, VS）。

## 設定

- **設定ファイル**: `JPEGView.ini`（ポータブルまたはシステムディレクトリ）
- **キーマップ**: `KeyMap.txt`
- **ローカライズ**: 28 言語対応（`strings_*.txt`）
