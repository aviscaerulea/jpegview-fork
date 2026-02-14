$tempDir = Join-Path $env:TEMP 'JPEGView-fork-1.3.46.0-20260214.1_x64'
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

$srcDir = 'src/JPEGView/bin/x64/Release'
$items = @(
    '*.exe',
    '*.dll',
    '*.ini',
    '*.ini.tpl',
    'KeyMap.txt.default',
    'KeyMap.txt.default_ru',
    'NavPanel.png',
    'symbols.km',
    'LICENSE.txt'
)

foreach ($item in $items) {
    Copy-Item "$srcDir/$item" $tempDir -ErrorAction SilentlyContinue
}

Copy-Item "$srcDir/language" $tempDir -Recurse
Copy-Item "$srcDir/doc" $tempDir -Recurse

Write-Host "Temp directory created: $tempDir"
$fileCount = (Get-ChildItem $tempDir -Recurse | Measure-Object).Count
Write-Host "Total files: $fileCount"

# Create zip
$zipPath = 'JPEGView-fork-1.3.46.0-20260214.1_x64.zip'
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path $tempDir -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "Zip created: $zipPath"
$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host "Zip size: $([Math]::Round($zipSize, 2)) MB"
