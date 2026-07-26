$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$baseUrl = "https://noscope-assets.pages.dev"

$imageFolders = @("Players", "Teams", "Sponsors", "Staffs", "Tournaments")
$databaseFolder = "Databases"

$manifest = [ordered]@{
    version = Get-Date -Format "yyyy.MM.dd.HHmm"
    baseUrl = $baseUrl
}

foreach ($folder in $imageFolders) {
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

$databases = @()
$databasePath = Join-Path $root $databaseFolder

if (Test-Path $databasePath) {
    $databases = Get-ChildItem -LiteralPath $databasePath -File -Filter "*.emdb" |
        Sort-Object Name |
        ForEach-Object {
            $encodedName = [Uri]::EscapeDataString($_.Name)
            [ordered]@{
                id = $_.BaseName.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant()
                name = $_.BaseName
                fileName = $_.Name
                path = "$databaseFolder/$encodedName"
                url = "$baseUrl/$databaseFolder/$encodedName"
                size = $_.Length
                updated = $_.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        }
}

$manifest[$databaseFolder] = $databases

$json = $manifest | ConvertTo-Json -Depth 8
Set-Content -LiteralPath (Join-Path $root "manifest.json") -Value $json -Encoding utf8

Write-Output "Generated manifest.json"