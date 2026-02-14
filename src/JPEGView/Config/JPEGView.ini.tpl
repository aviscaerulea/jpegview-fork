[JPEGView]

; このユーザ INI ファイルは JPEGView.ini.tpl テンプレートから生成されたものである
; このファイルの設定は EXE パスにあるグローバル INI ファイルの設定を上書きする


; *****************************************************************************
; * PROGRAM OPTIONS（プログラム設定）
; *
; * These options control how JPEGView operates（JPEGView の動作を制御する設定）
; *****************************************************************************

; true の場合、JPEGView は常に単一インスタンスで動作する（すべての画像を同じウィンドウで開く）
; false の場合、複数インスタンスの起動を許可する
SingleInstance=false

; true の場合、ファイル名パラメータなしで起動した際に「ファイルを開く」ダイアログを表示しない
SkipFileOpenDialogOnStartup=false

; WIC（Windows Image Converter）でデコードするファイルの拡張子
; Microsoft Camera Codec Pack がインストールされていれば、RAW ファイルを WIC で読み込める
; 閲覧したい RAW ファイルの拡張子をここに追加する
FilesProcessedByWIC=*.wdp;*.hdp;*.jxr

; カメラ RAW ファイルの拡張子（埋め込み JPEG サムネイルの表示対象）
; 埋め込み JPEG の読み込みは WIC での RAW デコードより大幅に高速
FileEndingsRAW=*.pef;*.dng;*.crw;*.nef;*.cr2;*.mrw;*.rw2;*.orf;*.x3f;*.arw;*.kdc;*.nrw;*.dcr;*.sr2;*.raf;*.kc2;*.erf;*.3fr;*.raw;*.mef;*.mos;*.mdc;*.cr3

; FileEndingsRAW に登録された RAW ファイルの表示方法
; 0: 埋め込みサムネイルを開く
; 1: フルサイズで開く
; 2: サムネイルを開き、失敗時はフルサイズにフォールバック
; 3: フルサイズで開き、失敗時はサムネイルにフォールバック
DisplayFullSizeRAW=0

; true の場合、ズーム・パン・コントラスト・ガンマ・シャープ・回転の設定を画像間で保持する
KeepParameters=false

; マルチモニタ環境専用の設定
; アプリケーションを起動するモニタを指定する
; -1: 最大解像度のモニタを使用（同一解像度が複数ある場合はプライマリモニタ）
;  0: プライマリモニタを使用
;  1...n: インデックス n の非プライマリモニタを使用
DisplayMonitor=-1

; CPUType は AutoDetect, Generic, MMX, SSE, AVX2 のいずれか
; Generic はすべての CPU で動作する。MMX は最低 MMX II（Pentium III 以降）が必要
; AutoDetect で最適なアルゴリズムを自動選択する
CPUType=AutoDetect

; 使用する CPU コア数。0 で自動検出（論理コア数）。0 または 1〜64 を指定。
CPUCoresUsed=0

; INI ファイルのエディタ設定
; notepad : notepad.exe を使用
; system : INI ファイルに関連付けされたアプリケーションを使用
; その他 : INI ファイル編集アプリケーションのフルパス（%exepath% プレースホルダ使用可）
IniEditor=system

; 加工済み画像をデスクトップ壁紙に設定する際の保存先パス
; デフォルトはシステムの TEMP ディレクトリ（%temp%）。指定ディレクトリへの書き込み権限が必要
WallpaperPath=%temp%

; false の場合、JPEGView での画像削除を無効化する
; ナビゲーションパネルの「x」ボタンを非表示にし、削除コマンドを無効化する
AllowFileDeletion=true



; *****************************************************************************
; * USER INTERFACE OPTIONS（ユーザインタフェース設定）
; *
; * These options control how JPEGView looks（JPEGView の外観を制御する設定）
; *****************************************************************************

; UI の表示言語。'auto' で OS の言語を使用する
; それ以外は ISO 639-1 言語コード（2 文字）で指定する
; Currently supported:
; 'bel'   Belorussian
; 'cs'    Czech
; 'de'    German
; 'el'    Greek
; 'en'    English (default)
; 'es'    Spanish (Spain)
; 'es-ar' Spanish (latinoamerica)
; 'eu'    Basque
; 'fr'    French
; 'it'    Italian
; 'ja'    Japanese
; 'ko'    Korean
; 'pl'    Polish
; 'pt'    Portuguese
; 'pt-br' Portuguese (Brasil)
; 'ro'    Romanian
; 'ru'    Russian
; 'sv'    Swedish
; 'uk'    Ukrainian
; 'zh'    Chinese
; 'zh-tw' Chinese (Taiwan)
Language=auto

; 背景色。R G B 形式で各値は 0〜255（例: "128 128 128" で中間グレー）
BackgroundColor=0 0 0

; GUI の各色。BackgroundColor と同じ R G B 形式
GUIColor=243 242 231
HighlightColor=255 205 0
SelectionColor=255 205 0
SliderColor=255 0 80
FileNameColor=255 255 255

; GUI フォント。形式: "フォント名" サイズ(pt) [bold]
; 'Default' で Windows のデフォルト GUI フォントを使用
DefaultGUIFont=Default

; true の場合、グローバル INI ファイルの編集メニュー項目を表示する
; 設定 > 管理サブメニューに表示される
AllowEditGlobalSettings=false

; -----------------------------------------------
; - WINDOW BEHAVIOR OPTIONS（ウィンドウの動作設定）
; -----------------------------------------------

; 起動時の画面モード
; 'true': 常にフルスクリーンで起動
; 'false': 常にウィンドウモードで起動
; 'auto': 最初の画像サイズに応じて自動選択（小さい画像はウィンドウ、大きい画像はフルスクリーン）
ShowFullScreen=auto

; true の場合、フルスクリーンモードでは単一インスタンスのみ許可
; SingleInstance=true の場合、この設定は無視される
SingleFullScreenInstance=true

; ウィンドウモードでのデフォルト位置とサイズ
; 'auto': 画面サイズの 2/3
; 'max': 最大化ウィンドウで起動
; 'image': 画像サイズに合わせて自動調整
; 'sticky': 前回のウィンドウサイズを復元（ShowFullScreen=auto の場合は左上位置のみ復元）
; 'left top right bottom': スペース区切りの座標指定（例: 100 100 900 700）
DefaultWindowRect=image

; DefaultWindowRect=sticky の場合に保存されるウィンドウ矩形
StickyWindowRect=

; ウィンドウモードでの最小ウィンドウサイズ（ピクセル単位）
MinimalWindowSize=320 240

; true の場合、ボーダーレスモードで起動する（タイトルバー非表示、手動リサイズ不可）
; 起動後にモード変更可能
WindowBorderlessOnStartup=false

; true の場合、常に最前面表示モードで起動する
; 起動後にモード変更可能
WindowAlwaysOnTopOnStartup=false

; -----------------------------------------------
; - IMAGE CONTROL PANELS（画像操作パネル）
; -----------------------------------------------

; true の場合、画面下部にマウスを移動するとボトムパネルを表示する
; ボトムパネルは基本的な画像処理機能を提供する
ShowBottomPanel=true

; false の場合、ナビゲーションパネルを画像上に重ねて表示しない
ShowNavPanel=true

; false の場合、ズーム・パン時のサムネイルナビゲータを無効化する
ShowZoomNavigator=true

; マウスがパネル外にあるときのナビゲーションパネルの透明度
; 0.0 にするとマウスがパネル上にあるときのみ表示する
BlendFactorNavPanel=0.5

; ナビゲーションパネルの拡大率。タッチスクリーン等でボタンが小さい場合は値を大きくする
ScaleFactorNavPanel=1.0



; *****************************************************************************
; * FILE NAVIGATION OPTIONS（ファイルナビゲーション設定）
; *
; * These options are related how JPEGView navigates and finds image files to display（JPEGView のファイル探索と画像表示に関する設定）
; *****************************************************************************

; フォルダ内の画像ファイルの並び替え順
; LastModDate, CreationDate, FileName, FileSize, Random のいずれか
FileDisplayOrder=LastModDate

; true の場合、昇順（A→Z, 0→9）、false の場合、降順（Z→A, 9→0）
FileSortAscending=true

; フォルダ間のナビゲーション動作
; LoopFolder: 同一フォルダ内でループ（フォルダを離れない）
; LoopSameFolderLevel: 同じ階層の隣接フォルダへループ
; LoopSubFolders: サブフォルダも含めてループ
FolderNavigation=LoopFolder

; true の場合、最後の画像から最初の画像へ（またはその逆）ループする
; false の場合、最初と最後の画像で停止する
WrapAroundFolder=true

; WrapAroundFolder=false 時、ファイルリストの末尾/先頭を超えて移動しようとした場合の動作
; true の場合、これ以上画像がないときにウィンドウを一瞬フラッシュする
; false の場合、視覚的なフィードバックなし
FlashWindowAlert=true

; WrapAroundFolder=false 時、ファイルリストの末尾/先頭を超えて移動しようとした場合の動作
; true の場合、これ以上画像がないときにシステムのデフォルトサウンドでビープ音を鳴らす
; false の場合、音声フィードバックなし
BeepSoundAlert=false

; -----------------------------------------------
; - MOUSE NAVIGATION OPTIONS（マウスナビゲーション設定）
; -----------------------------------------------

; true の場合、マウスホイールで前後ナビゲーション、ズームは Ctrl+マウスホイール
; false の場合、マウスホイールでズーム（Ctrl 不要）
NavigateWithMouseWheel=true

; true の場合、拡張マウスボタン（進む/戻る）の動作を反転する
; より押しやすいボタンに「次の画像」機能を割り当てるのに便利
ExchangeXButtons=true



; *****************************************************************************
; * USER INPUT CONFIG（ユーザ入力設定）
; *
; * These options control interactions with JPEGView（JPEGView の操作に関する設定）
; *****************************************************************************

; デフォルトでは、パンが使用できないとき左クリック＋ドラッグで選択モードになる
; ズーム中は Ctrl+左クリック＋ドラッグで選択モードになる
; false の場合、Ctrl を押したときのみ選択モードを使用する
DefaultSelectionMode=true

; マウスホイールのズーム速度。1.0 がデフォルト速度、小さいほど遅く、大きいほど速い
MouseWheelZoomSpeed=1.0



; *****************************************************************************
; * IMAGE DISPLAY OPTIONS（画像表示設定）
; *
; * These options are related to how JPEGView displays images（JPEGView の画像表示に関する設定）
; *****************************************************************************

; true の場合、外部プログラムによってディスク上の画像が変更されたとき自動的に再読み込みする
; 現在のディレクトリでファイルの追加・削除があった場合も画像リストを再読み込みする
ReloadWhenDisplayedImageChanged=true

; true の場合、高品質リサンプリングをデフォルトで使用する
HighQualityResampling=true

; ダウンサンプリングフィルタ。BestQuality, NoAliasing, Narrow のいずれか
; BestQuality: エイリアシングがごくわずか
; NoAliasing: シャープ値 0 でほぼエイリアシングのない Lanczos フィルタ
; Narrow: エイリアシングは多いが強力なシャープ効果（100% 表示の画像にも有効）
DownSamplingFilter=BestQuality

; true の場合、EXIF の画像方向タグに従って JPEG 画像を自動回転する
AutoRotateEXIF=true

; キーボードやマウスで手動ナビゲーション時の画像の最小表示時間（ミリ秒、0〜1000）
MinimalDisplayTime=0

; JPEG 読み込みに GDI+ を強制使用する。デフォルトの Turbo JPEG ライブラリで問題がある場合のみ使用
; GDI+ は Turbo JPEG より低速
; （true にするとアニメーション PNG サポートが自動的に無効化される）
ForceGDIPlus=false

; true の場合、JPEG, PNG, TIFF の埋め込み ICC カラープロファイルを使用する
; GDI+ の使用が強制されるため JPEG の読み込みが大幅に遅くなる。本当に必要な場合のみ有効にすること
UseEmbeddedColorProfiles=false

; -----------------------------------------------
; - TRANSPARENCY OPTIONS（透過表示設定）
; -----------------------------------------------

; 画像の透過部分に使用する色。BackgroundColor と同じ R G B 形式
TransparencyColor=0 0 0

; -----------------------------------------------
; - IMAGE ZOOM OPTIONS（画像ズーム設定）
; -----------------------------------------------

; 自動ズームモード（AutoZoomModeFullscreen が設定されている場合、ウィンドウモードのみに適用）
; FitNoZoom: 画面に収まるよう縮小（拡大はしない）
; FillNoZoom: 黒帯なしで画面を埋める（必要に応じてクロップ、拡大はしない）
; Fit: 画面に収まるよう拡大/縮小
; Fill: 黒帯なしで画面を埋める（必要に応じてクロップ）
AutoZoomMode=FitNoZoom

; フルスクリーンモードでの自動ズームモード。空の場合は AutoZoomMode と同じ値を使用
AutoZoomModeFullscreen=

; 連続ズーム時に指定パーセントで一時停止する（デフォルト: 100%）
; 画像サイズやズームステップに関係なく、指定パーセントに確実に到達できる
; 0 に設定すると一時停止を無効化
ZoomPausePercent=100

; -----------------------------------------------
; - ADVANCED IMAGE CORRECTION PARAMETERS（画像補正の詳細パラメータ）
; -----------------------------------------------

; すべての画像に適用するコントラスト補正値。-0.5〜0.5
; 正の値でコントラスト増加、負の値で減少
Contrast=0.0

; すべての画像に適用するガンマ補正値。0.5〜2.0
; 1 未満で明るく、1 より大きいと暗くなる
Gamma=1.0

; すべての画像に適用する彩度。0.0〜2.0
; 0.0: グレースケール、1.0: 彩度変更なし、2.0: 最大彩度
Saturation=1.0

; ダウンサンプリング画像に適用するシャープネス。0〜0.5
; 100% ズームでは BestQuality フィルタはシャープ処理を適用しない（他のフィルタのみ有効）
Sharpen=0.3



; *****************************************************************************
; * DEFAULT IMAGE EDITING OPTIONS（画像編集のデフォルト設定）
; *
; * These options are related to JPEGView defaults for image editing（JPEGView の画像編集デフォルト値に関する設定）
; *****************************************************************************

; アンシャープマスクのデフォルトパラメータ: 半径 適用量 しきい値
; 全画像への自動適用は不可。アンシャープマスクモード開始時のデフォルト値として使用される
UnsharpMaskParameters=1.0 1.0 4.0

; 回転およびパース補正のデフォルトパラメータ
RTShowGridLines=true
RTAutoCrop=true
RTPreserveAspectRatio=true

; デフォルトのカラーバランス。負の値で C,M,Y 補正、正の値で R,G,B 補正
; 値は -1.0〜+1.0
CyanRed=0.0
MagentaGreen=0.0
YellowBlue=0.0

; -----------------------------------------------
; - CROP OPTIONS（クロップ設定）
; -----------------------------------------------

; 「固定サイズ」クロップモード使用時の初期クロップウィンドウサイズ
DefaultFixedCropSize=320 200

; ユーザ定義のクロップアスペクト比（x y）、意味は x : y
; クロップポップアップメニューの最後に表示される
UserCropAspectRatio=14 11



; *****************************************************************************
; * IMAGE INFO DISPLAY OPTIONS（画像情報表示設定）
; *
; * These options control the information box for when viewing images（画像閲覧時の情報ボックスを制御する設定）
; *****************************************************************************

; ウィンドウタイトルに EXIF の撮影日を表示する
ShowEXIFDateInTitle=true

; ウィンドウタイトルにファイルのフルパスを表示する（デフォルトはファイル名のみ）
ShowFilePathInTitle=false

; -----------------------------------------------
; - FILE NAME AREA（ファイル名表示エリア）
; -----------------------------------------------

; true の場合、画面左上に各画像のファイル名を表示する
ShowFileName=false

; ファイル名表示に含める要素
; 使用可能な要素:
; %filename% : ファイル名
; %filepath% : ファイル名とパス
; %index%    : フォルダ内の画像インデックス（例: [1/12]）
; %zoom%     : 現在のズーム倍率
; %size%     : 画像のピクセルサイズ（幅 x 高さ）
; %filesize% : ディスク上のファイルサイズ
FileNameFormat=%index%  %filepath%

; ファイル名表示のフォント。形式は DefaultGUIFont を参照
FileNameFont=Default

; -----------------------------------------------
; - FILE EXIF INFO BOX（EXIF 情報ボックス）
; -----------------------------------------------

; true の場合、ファイル情報ボックスを初期表示する（利用可能な場合は EXIF 情報を表示）
ShowFileInfo=false

; true の場合、ファイル情報ボックスに JPEG コメント（EXIF ユーザコメント、画像説明、JPEG コメント）を表示する
ShowJPEGComments=true

; true の場合、ファイル情報パネルにヒストグラムをデフォルトで表示する
ShowHistogram=false

; GPS 座標を地図上に表示するための地図プロバイダ URL（EXIF に GPS 座標がある場合のみ表示）
GPSMapProvider=https://opentopomap.org/#marker=15/{lat}/{lng}



; *****************************************************************************
; * AUTOMATIC CORRECTION OPTIONS（自動補正設定）
; *
; * These options control how and when automatic correction is applied（自動補正の適用方法とタイミングを制御する設定）
; *****************************************************************************

; -----------------------------------------------
; - AUTO CONTRAST CORRECTION（自動コントラスト補正）
; -----------------------------------------------

; ヒストグラム均等化による自動コントラスト補正
; F5 キーで現在の画像に対する補正の有効/無効を切り替える
AutoContrastCorrection=false

; 以下の 2 つのキーで、コントラスト補正の対象フォルダを明示的に除外/包含できる
; より具体的なパターンが優先され、両方に一致する場合は包含が優先される
; セミコロン ; で複数の式を区切る
; 例: ACCExclude=%mypictures%\Digicam\edited\*;*.bmp
;   → マイピクチャ\Digicam\edited\ 以下の全ファイルと全 BMP ファイルを除外
; 使用可能なプレースホルダ:
;   %mypictures%  : 「マイドキュメント\マイピクチャ」フォルダ
;   %mydocuments% : 「マイドキュメント」フォルダ
ACCExclude=
ACCInclude=

; 自動コントラスト補正の適用量
; 0: 補正なし、1: 完全補正（黒点・白点まで）。値は 0〜1
AutoContrastCorrectionAmount=0.5

; -----------------------------------------------
; - AUTO COLOR CORRECTION（自動カラー補正）
; -----------------------------------------------

; 各色チャネル（赤, 緑, 青, シアン, マゼンタ, イエロー）の補正量
; 値は 0.0（補正なし）〜1.0（グレーワールドモデルへの完全補正）
; すべて 0 に設定するとカラー補正を無効化
ColorCorrection= R: 0.2 G: 0.1 B: 0.35 C: 0.1 M: 0.3 Y: 0.15

; -----------------------------------------------
; - AUTO BRIGHTNESS CORRECTION（自動明るさ補正）
; -----------------------------------------------

; 自動明るさ補正の適用量
; 0: 補正なし、1: 中間グレーへの完全補正。値は 0〜1
AutoBrightnessCorrectionAmount=0.2

; -----------------------------------------------
; - AUTO LOCAL DENSITY CORRECTION（自動ローカル濃度補正）
; -----------------------------------------------

; ローカル濃度（画像の局所的な明るさ）の自動補正
; F6 キーで現在の画像に対する補正の有効/無効を切り替える
LocalDensityCorrection=false

; 除外/包含については ACCExclude の説明を参照。同じ仕様が適用される
LDCExclude=
LDCInclude=

; シャドウに対するローカル濃度補正の適用量。0〜1
LDCBrightenShadows=0.5

; ディープシャドウの強調の急峻度。0〜1（0.9 を超える値は非推奨）
LDCBrightenShadowsSteepness=0.5

; ハイライトに対するローカル濃度補正の適用量。0〜1
LDCDarkenHighlights=0.25

; -----------------------------------------------
; - AUTO LANDSCAPE MODE CORRECTION（自動風景モード補正）
; -----------------------------------------------

; true の場合、風景モード補正を自動的に有効にする
LandscapeMode=false

; 風景モード補正で使用するパラメータセット
; スペース区切り、-1 でそのパラメータを変更しない
; コントラスト ガンマ シャープ カラー補正 コントラスト補正 シャドウ明化 ハイライト暗化 ディープシャドウ シアン-赤 マゼンタ-緑 イエロー-青 彩度
LandscapeModeParams=-1 -1 -1 -1 0.5 1.0 0.75 0.4 -1 -1 -1 -1



; *****************************************************************************
; * SLIDESHOW OPTIONS（スライドショー設定）
; *
; * These options control slideshow parameters（スライドショーのパラメータを制御する設定）
; *****************************************************************************

; スライドショー用テキストファイルの最大サイズ（KB）
MaxSlideShowFileListSizeKB=200

; フルスクリーンモードでのスライドショーのトランジション効果（ウィンドウモードでは無視）
; 使用可能な効果: None, Blend, SlideRL, SlideLR, SlideTB, SlideBT, RollRL, RollLR, RollTB, RollBT, ScrollRL, ScrollLR, ScrollTB, ScrollBT
SlideShowTransitionEffect=Blend

; スライドショーのトランジション効果の時間（ミリ秒）。フルスクリーンモードのみ有効
SlideShowEffectTime=250



; *****************************************************************************
; * CONFIRMATION OPTIONS（確認ダイアログ設定）
; *
; * These options control whether or not to bypass confimation dialogs（確認ダイアログの表示/非表示を制御する設定）
; *****************************************************************************

; true の場合、Ctrl+S でダイアログを表示せずに元のファイルを上書き保存する
; 注意: 自己責任で使用すること。元の画像ファイルは復元できなくなる
OverwriteOriginalFileWithoutSaveDialog=false

; true の場合、ロスレス JPEG 変換時にユーザに確認せずに画像をトリムする
; 最悪の場合、画像の端から 15 ピクセルの行/列が削除される
; 注意: 自己責任で使用すること。元のファイルは上書きされ、トリムされた部分は復元できない
TrimWithoutPromptLosslessJPEG=false

; ナビゲーションパネルの「x」ボタンでファイルを削除する際の確認方法
; Never: 確認しない、OnlyWhenNoRecycleBin: ごみ箱が利用できない場合のみ確認、Always: 常に確認
; OnlyWhenNoRecycleBin は USB メモリ等でごみ箱が利用できない場合のみ確認する
; 注意: Del キーでの削除には適用されない。変更するには KeyMap.txt を編集すること
DeleteConfirmation=OnlyWhenNoRecycleBin



; *****************************************************************************
; * FILE SAVE OPTIONS（ファイル保存設定）
; *
; * These options control file saving parameters（ファイル保存のパラメータを制御する設定）
; *****************************************************************************

; ファイル保存のデフォルト形式。対応形式: jpg, bmp, png, tif, webp
DefaultSaveFormat=jpg

; JPEG 保存時の品質（0〜100、100 が最高品質）
JPEGSaveQuality=85

; WEBP の非可逆圧縮保存時の品質（0〜100、100 が最高品質）
WEBPSaveQuality=85

; true の場合、JPEGView で画像を保存する際にパラメータ DB エントリを作成し、再処理を防ぐ
CreateParamDBEntryOnSave=true


; *****************************************************************************
; * PRINT OPTIONS（印刷設定）
; *
; * These options control printing images（画像の印刷を制御する設定）
; *****************************************************************************

; デフォルトの印刷マージン（全辺）。単位: センチメートル
PrintMargin=1.0

; デフォルトの印刷幅。単位: センチメートル。負の値で「用紙に合わせる」印刷モード
PrintWidth=-15.0

; 使用する単位。'auto', 'metric', 'english' のいずれか
; 'auto': システム設定に従う
; 'metric': メートル法（センチメートル等）
; 'english': ヤード・ポンド法（インチ等）
Units=auto



; *****************************************************************************
; * CUSTOM USER COMMANDS（カスタムユーザコマンド）
; *
; * These are custom user commands that can easily extend the functionality in JPEGView（JPEGView の機能を拡張するカスタムユーザコマンド）
; *****************************************************************************

; ユーザコマンドは以下の形式で定義する:
; UserCmd#="KeyCode: %Key% Cmd: '%Cmd%' [Menuitem: '%menu%'] [Confirm: '%confirm%'] [HelpText: '%help%'] [Flags: '%flags%']"
;
; %Key% :     コマンドを呼び出すキー。JPEGView で既に使用されているキーは定義しないこと
;             使用可能なキー: Alt, Ctrl, Shift, Esc, Return, Space, End, Home, Back, Tab, PgDn, PgUp,
;             Left, Right, Up, Down, Insert, Del, Plus, Minus, Mul, Div, Comma, Period, A .. Z  F1 .. F12
;             修飾キーは + で結合（例: 'Alt+Ctrl+P'）
; %Cmd% :     起動するアプリケーション（コマンド引数を含む）。パスにスペースがある場合はダブルクォートで囲む
;             コマンドラインコマンドやバッチファイルを実行するには 'cmd /c command' や 'cmd /c MyBatchFile.bat' を使用する
;             %Cmd% 引数で使用可能なプレースホルダ:
;             %filename%   : 現在の画像のファイル名（パス付き）
;             %filetitle%  : 現在の画像のファイル名（パスなし）
;             %directory%  : 現在の画像のディレクトリ（末尾のバックスラッシュなし）
;             %mydocuments%: 「マイドキュメント」フォルダ（末尾のバックスラッシュなし）
;             %mypictures% : 「マイピクチャ」フォルダ（末尾のバックスラッシュなし）
;             %exepath%    : JPEGView の EXE フォルダのパス
;             %exedrive%   : EXE パスのドライブレター（例: "c:"）
;             プレースホルダの前後にバックスラッシュがない場合、結果はダブルクォートで自動的に囲まれる
; %menu% :    JPEGView コンテキストメニューの「ユーザコマンド」サブメニューに表示するメニュー項目テキスト
;             省略するとメニューに表示されない
; %confirm% : コマンド実行前に表示される確認メッセージ
;             省略可。省略時は確認なしで実行される
; %help% :    F1 キー押下時に表示されるヘルプ文字列
;             省略可。省略時はヘルプテキストなし
; %flags% :   以下のフラグをサポート:
;             NoWindow :         コンソールアプリケーション用。設定するとコンソールウィンドウを表示しない
;                                起動アプリケーションが cmd.exe の場合、このフラグは暗黙的に設定される
;             ShortFilename :    設定すると、短い（8.3 形式の）ファイル名とパスを実行アプリケーションに渡す
;                                実行アプリケーションが長いファイル名やスペースを含むパスを処理できない場合に設定する
;             WaitForTerminate : 設定すると、コマンドの実行完了まで JPEGView をブロックする
;                                未設定の場合、コマンドを起動後 JPEGView は続行する
;             MoveToNext :       設定すると、コマンド実行後にフォルダ内の次の画像に移動する
;                                ReloadCurrent フラグとの併用は不可
;             ReloadFileList :   設定すると、コマンド実行後に現在のフォルダのファイルリストを再読み込みする
;                                コマンドがフォルダの内容を変更する場合（移動、リネーム、削除等）に設定する
;             ReloadCurrent :    設定すると、コマンド実行後に現在表示中のファイルをディスクから再読み込みする
;                                コマンドが現在の画像のピクセルデータを変更する場合に設定する
;             ReloadAll:         設定すると、ファイルリストの再読み込みと、現在の画像およびキャッシュ済み画像を再読み込みする
;                                コマンドが現在の画像以外のピクセルデータを変更する場合のみ設定する
;             KeepModDate:       現在の画像の更新日時を保持する。ソート順を維持するために使用できる
;                                注意: このフラグを使用する場合、必ず WaitForTerminate フラグと併用すること
;             ShellExecute:      CreateProcess() の代わりに ShellExecute() システムコールを使用して外部プロセスを起動する
;                                一部のアプリケーションは CreateProcess() では正常に起動しない
;                                このフラグを設定した場合、WaitForTerminate は使用不可
;                                WaitForTerminate を必要とする他のフラグも使用不可
;                                通常、画像エディタ等の大型外部アプリケーションの起動に使用する
;
; ユーザコマンドは UserCmd# という名前にする（# は番号）
; 最初のユーザコマンドは 0（UserCmd0）で、番号は連番でなければならない

; 重要: UserCmd0 はグローバル INI で既に使用されている。グローバル INI の画像削除コマンドを上書きする場合を除き、UserCmd1 から開始すること


; 以下はユーザコマンドの例
;UserCmd1="KeyCode: P  Cmd: 'C:\WINDOWS\system32\mspaint.exe /p %filename%' Menuitem: 'Print Image' Confirm: 'Do you really want to print the file %filename%?' HelpText: 'P\tPrint current image'"
;UserCmd2="KeyCode: Q  Cmd: 'cmd /c move %filename% "%mypictures%\trash\"' Confirm: 'Really move file to %mypictures%\trash\%filetitle%' HelpText: 'Q\tMove file to trash directory' Flags: 'WaitForTerminate ReloadFileList MoveToNext'"
;UserCmd3="KeyCode: W  Cmd: 'cmd /c copy %filename% "%mypictures%\trash\%filetitle%"' Confirm: 'Really copy file to %mypictures%\trash\%filetitle%' HelpText: 'W\tCopy file to trash directory' Flags: 'WaitForTerminate'"
;UserCmd4="KeyCode: A  Cmd: 'cmd /u /c echo %filename% >> "%mydocuments%\test.txt"' HelpText: 'A\tAppend to file list'"

; -----------------------------------------------
; - OPEN WITH COMMANDS（外部アプリで開くコマンド）
; -----------------------------------------------

; 「プログラムから開く」コマンド。JPEGView コンテキストメニューの「プログラムから開く」サブメニューに表示される
;
; コマンドは OpenWith# という名前にする（# は番号）。最初のコマンドは OpenWith0 で、番号は連番でなければならない
;
; 形式:
;     OpenWith#="Cmd: '%Cmd%' Menuitem: '%menu%' [KeyCode: %Key%] [Confirm: '%confirm%'] [Flags: '%flags%']"
;
; 各オプションの説明は上記のユーザコマンドのドキュメントを参照
;
; MS ペイントで現在の画像を開くメニュー項目の例:
;OpenWith0="Cmd: 'C:\WINDOWS\system32\mspaint.exe %filename%' Menuitem: 'Microsoft Paint' Flags: 'ShellExecute'"
