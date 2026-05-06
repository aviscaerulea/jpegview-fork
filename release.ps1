<#
.SYNOPSIS
    JPEGView-nt リリース自動化スクリプト

.DESCRIPTION
    バージョン文字列を引数として渡すだけで、ソース更新から GitHub リリース作成までを
    一貫して自動化する。ビルド・zip 作成は GitHub Actions が担う。

    処理フロー:
    1. バリデーション（バージョン形式、未コミット、必要ツール）
    2. ソース更新（resource.h, JPEGView.rc）
    3. git commit
    4. git tag + push + GitHub release 作成（zip は GHA が後付けでアップロード）

.PARAMETER Version
    バージョン文字列（例: 1.3.46.0-20260215.1）

.PARAMETER DryRun
    変更内容を表示するだけで実行しない

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
}
else {
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
}
else {
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
if ($LASTEXITCODE -ne 0) {
    Write-Error "git commit に失敗しました（Exit code: $LASTEXITCODE）"
    exit 1
}

Write-Host "==> git commit 完了" -ForegroundColor Green

# =============================================================================
# リリース
# =============================================================================

if ($SkipRelease) {
    Write-Host "==> GitHub リリース作成スキップ（-SkipRelease 指定）" -ForegroundColor Yellow
}
else {
    Write-Host "==> GitHub リリース作成中..." -ForegroundColor Cyan

    # release-notes.txt の存在確認
    if (-not (Test-Path "release-notes.txt")) {
        Write-Error "release-notes.txt が存在しません（リリースノートは事前に準備してください）"
        exit 1
    }

    # git tag
    git tag "v$Version"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git tag に失敗しました（Exit code: $LASTEXITCODE）"
        exit 1
    }
    Write-Host "  git tag 作成: v$Version" -ForegroundColor Green

    # git push
    git push aviscaerulea master
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git push (master) に失敗しました（Exit code: $LASTEXITCODE）"
        exit 1
    }
    Write-Host "  git push 完了: aviscaerulea/master" -ForegroundColor Green

    git push aviscaerulea "v$Version"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git push (tag) に失敗しました（Exit code: $LASTEXITCODE）"
        exit 1
    }
    Write-Host "  git push 完了: aviscaerulea/v$Version" -ForegroundColor Green

    # gh release create（ビルド成果物は GitHub Actions が後付けでアップロード）
    gh release create "v$Version" `
        --repo aviscaerulea/jpegview-nt `
        --title "v$Version" `
        --notes-file release-notes.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Error "gh release create に失敗しました（Exit code: $LASTEXITCODE）"
        exit 1
    }

    Write-Host "  GitHub リリース作成完了: v$Version" -ForegroundColor Green

    # リリースページを開く
    $releaseUrl = "https://github.com/aviscaerulea/jpegview-nt/releases/tag/v$Version"
    Start-Process $releaseUrl
    Write-Host "  リリースページを開きました: $releaseUrl" -ForegroundColor Green
}

Write-Host ""
Write-Host "==> すべての処理が完了しました！" -ForegroundColor Cyan
