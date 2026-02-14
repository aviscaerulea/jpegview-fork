<#
.SYNOPSIS
    JPEGView-nt リリース自動化スクリプト

.DESCRIPTION
    バージョン文字列を引数として渡すだけで、ソース更新からリリースまでを一貫して自動化する。

    処理フロー:
    1. バリデーション（バージョン形式、未コミット、必要ツール）
    2. ソース更新（resource.h, JPEGView.rc）
    3. git commit
    4. msbuild（Release|x64 リビルド）
    5. zip 作成
    6. git tag + push + GitHub release 作成

.PARAMETER Version
    バージョン文字列（例: 1.3.46.0-20260215.1）

.PARAMETER DryRun
    変更内容を表示するだけで実行しない

.PARAMETER SkipBuild
    ビルド済みの場合にビルドをスキップ

.PARAMETER SkipRelease
    GitHub リリース作成をスキップ（ローカルまで）

.EXAMPLE
    .\release.ps1 -Version "1.3.46.0-20260215.1"

.EXAMPLE
    .\release.ps1 -Version "1.3.46.0-20260215.1" -DryRun

.EXAMPLE
    .\release.ps1 -Version "1.3.46.0-20260215.1" -SkipRelease
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [switch]$SkipBuild,

    [Parameter(Mandatory = $false)]
    [switch]$SkipRelease
)

$ErrorActionPreference = "Stop"

# =============================================================================
# バリデーション
# =============================================================================

Write-Host "==> バリデーション中..." -ForegroundColor Cyan

# バージョン文字列の形式チェック
if ($Version -notmatch '^\d+\.\d+\.\d+\.\d+-\d{8}\.\d+$') {
    Write-Error "バージョン形式が不正: $Version (例: 1.3.46.0-20260215.1)"
    exit 1
}

# 未コミットファイルの確認（警告のみ）
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Warning "未コミットファイルが存在します:"
    Write-Host $gitStatus -ForegroundColor Yellow
}

# 必要ツールの存在確認
$tools = @('git', 'gh')
foreach ($tool in $tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Error "$tool が見つかりません"
        exit 1
    }
}

# msbuild は Enable-VSDev 後に使用可能になるため、ここではチェックしない

Write-Host "==> バリデーション完了" -ForegroundColor Green

# =============================================================================
# ソース更新
# =============================================================================

Write-Host "==> ソース更新中..." -ForegroundColor Cyan

$resourceH = "src/JPEGView/resource.h"
$jpegviewRc = "src/JPEGView/JPEGView.rc"

# resource.h の JPEGVIEW_VERSION を置換
$resourceHContent = Get-Content $resourceH -Raw -Encoding UTF8
$resourceHOriginal = $resourceHContent
$resourceHContent = $resourceHContent -replace '#define JPEGVIEW_VERSION ".*?"', "#define JPEGVIEW_VERSION `"$Version\0`""

if ($DryRun) {
    Write-Host "[DryRun] resource.h の変更内容:" -ForegroundColor Magenta
    if ($resourceHOriginal -match '#define JPEGVIEW_VERSION ".*?"') {
        $oldLine = $Matches[0]
        Write-Host "  - $oldLine" -ForegroundColor Red
    }
    if ($resourceHContent -match '#define JPEGVIEW_VERSION ".*?"') {
        $newLine = $Matches[0]
        Write-Host "  + $newLine" -ForegroundColor Green
    }
} else {
    Set-Content $resourceH -Value $resourceHContent -Encoding UTF8 -NoNewline
    Write-Host "  $resourceH 更新完了" -ForegroundColor Green
}

# JPEGView.rc の FileVersion / ProductVersion を置換
$rcContent = Get-Content $jpegviewRc -Raw -Encoding UTF8
$rcOriginal = $rcContent
$rcContent = $rcContent -replace 'VALUE "FileVersion", ".*?"', "VALUE `"FileVersion`", `"$Version`""
$rcContent = $rcContent -replace 'VALUE "ProductVersion", ".*?"', "VALUE `"ProductVersion`", `"$Version`""

if ($DryRun) {
    Write-Host "[DryRun] JPEGView.rc の変更内容:" -ForegroundColor Magenta

    # FileVersion の変更を表示
    if ($rcOriginal -match 'VALUE "FileVersion", ".*?"') {
        $oldFileVersion = $Matches[0]
        Write-Host "  - $oldFileVersion" -ForegroundColor Red
    }
    if ($rcContent -match 'VALUE "FileVersion", ".*?"') {
        $newFileVersion = $Matches[0]
        Write-Host "  + $newFileVersion" -ForegroundColor Green
    }

    # ProductVersion の変更を表示
    if ($rcOriginal -match 'VALUE "ProductVersion", ".*?"') {
        $oldProductVersion = $Matches[0]
        Write-Host "  - $oldProductVersion" -ForegroundColor Red
    }
    if ($rcContent -match 'VALUE "ProductVersion", ".*?"') {
        $newProductVersion = $Matches[0]
        Write-Host "  + $newProductVersion" -ForegroundColor Green
    }
} else {
    Set-Content $jpegviewRc -Value $rcContent -Encoding UTF8 -NoNewline
    Write-Host "  $jpegviewRc 更新完了" -ForegroundColor Green
}

Write-Host "==> ソース更新完了" -ForegroundColor Green

if ($DryRun) {
    Write-Host "[DryRun] ドライランモードのため、以降の処理をスキップ" -ForegroundColor Magenta
    exit 0
}

# =============================================================================
# git commit
# =============================================================================

Write-Host "==> git commit 中..." -ForegroundColor Cyan

git add $resourceH $jpegviewRc
git commit -m "バージョン更新: v$Version"

Write-Host "==> git commit 完了" -ForegroundColor Green

# =============================================================================
# ビルド
# =============================================================================

if ($SkipBuild) {
    Write-Host "==> ビルドスキップ（-SkipBuild 指定）" -ForegroundColor Yellow
} else {
    Write-Host "==> ビルド中..." -ForegroundColor Cyan

    $buildCmd = @"
Enable-VSDev; msbuild src/JPEGView/JPEGView.vcxproj /p:Configuration=Release /p:Platform=x64 /t:Rebuild /m:8 /v:minimal /nologo
"@

    pwsh -Command $buildCmd
    $buildExitCode = $LASTEXITCODE

    # EXE の存在を確認
    $exePath = "src/JPEGView/bin/x64/Release/JPEGView.exe"
    if (-not (Test-Path $exePath)) {
        Write-Error "ビルドに失敗しました（EXE が生成されていません）"
        exit 1
    }

    if ($buildExitCode -ne 0) {
        Write-Warning "msbuild が警告/エラーを返しましたが、EXE は生成されています（Exit code: $buildExitCode）"
    }

    # post-build イベントを手動実行（Config ファイルと DLL のコピー）
    Write-Host "  post-build イベントを実行中..." -ForegroundColor Cyan
    $postBuildCmd = @"
cmd /c 'extras\scripts\JPEGView.vcxproj-postbuild-event.bat' '64' 'JPEGView' 'src\JPEGView\' 'src\JPEGView\bin\x64\Release\'
"@
    pwsh -Command $postBuildCmd | Out-Null

    Write-Host "==> ビルド完了" -ForegroundColor Green
}

# =============================================================================
# zip 作成
# =============================================================================

Write-Host "==> zip 作成中..." -ForegroundColor Cyan

$tempDir = Join-Path $env:TEMP "JPEGView-nt-${Version}_x64"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

$srcDir = 'src/JPEGView/bin/x64/Release'
$items = @(
    '*.exe',
    '*.dll',
    '*.ini',
    '*.ini.tpl',
    'KeyMap.txt.default',
    'NavPanel.png',
    'symbols.km',
    'LICENSE.txt'
)

foreach ($item in $items) {
    Copy-Item "$srcDir/$item" $tempDir -ErrorAction SilentlyContinue
}

Copy-Item "$srcDir/language" $tempDir -Recurse
Copy-Item "$srcDir/doc" $tempDir -Recurse

$fileCount = (Get-ChildItem $tempDir -Recurse | Measure-Object).Count
Write-Host "  一時ディレクトリ作成: $tempDir ($fileCount ファイル)" -ForegroundColor Green

$zipPath = "JPEGView-nt-${Version}_x64.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path $tempDir -DestinationPath $zipPath -CompressionLevel Optimal

$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host "  zip 作成完了: $zipPath ($([Math]::Round($zipSize, 2)) MB)" -ForegroundColor Green

# =============================================================================
# リリース
# =============================================================================

if ($SkipRelease) {
    Write-Host "==> GitHub リリース作成スキップ（-SkipRelease 指定）" -ForegroundColor Yellow
} else {
    Write-Host "==> GitHub リリース作成中..." -ForegroundColor Cyan

    # release-notes.txt の存在確認
    if (-not (Test-Path "release-notes.txt")) {
        Write-Error "release-notes.txt が存在しません（リリースノートは事前に準備してください）"
        exit 1
    }

    # git tag
    git tag "v$Version"
    Write-Host "  git tag 作成: v$Version" -ForegroundColor Green

    # git push
    git push aviscaerulea master
    Write-Host "  git push 完了: aviscaerulea/master" -ForegroundColor Green

    git push aviscaerulea "v$Version"
    Write-Host "  git push 完了: aviscaerulea/v$Version" -ForegroundColor Green

    # gh release create
    gh release create "v$Version" `
        --repo aviscaerulea/jpegview-nt `
        --title "v$Version" `
        --notes-file release-notes.txt `
        $zipPath

    Write-Host "  GitHub リリース作成完了: v$Version" -ForegroundColor Green

    # リリースページを開く
    $releaseUrl = "https://github.com/aviscaerulea/jpegview-nt/releases/tag/v$Version"
    Start-Process $releaseUrl
    Write-Host "  リリースページを開きました: $releaseUrl" -ForegroundColor Green
}

Write-Host ""
Write-Host "==> すべての処理が完了しました！" -ForegroundColor Cyan
