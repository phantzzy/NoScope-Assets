$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$baseUrl = "https://noscope-assets.pages.dev"
$folders = @("Players", "Teams", "Sponsors", "Staffs", "Tournaments")
$manifest = [ordered]@{
    version = Get-Date -Format "yyyy.MM.dd.HHmm"
    baseUrl = $baseUrl
}

foreach ($folder in $folders) {
    $entries = [ordered]@{}
    $folderPath = Join-Path $root $folder

    if (Test-Path $folderPath) {
        Get-ChildItem -LiteralPath $folderPath -File -Filter "*.png" |
            Sort-Object Name |
            ForEach-Object {
                $key = $_.BaseName.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant()
                $encodedName = [Uri]::EscapeDataString($_.Name)
                $entries[$key] = "$folder/$encodedName"
            }
    }

    $manifest[$folder] = $entries
}

$json = $manifest | ConvertTo-Json -Depth 5
Set-Content -LiteralPath (Join-Path $root "manifest.json") -Value $json -Encoding utf8

Write-Output "Generated manifest.json"