[CmdletBinding()]
param(
    [switch] $Force
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).ProviderPath
$configPath = Join-Path $root "ezo-addon.json"
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$addon = $config.addon
$package = $addon.package

$outputDirectory = Join-Path $root $package.outputPath
$zipPath = Join-Path $outputDirectory $package.zipName

if ((Test-Path -LiteralPath $zipPath) -and -not $Force) {
    throw "Package already exists: $zipPath. Use -Force to overwrite it."
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ezoalerts-package-" + [System.Guid]::NewGuid().ToString("N"))
$stagingRoot = Join-Path $tempRoot $package.rootFolderName

New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

try {
    $files = @(
        "EZOAlerts.txt",
        "EZOAlerts.lua",
        "lang/en.lua",
        "lang/es.lua",
        "modules/i18n.lua",
        "modules/core.lua",
        "modules/saved_vars.lua",
        "modules/alert_registry.lua",
        "modules/renderer.lua",
        "modules/menu.lua"
    )

    foreach ($relative in $files) {
        $source = Join-Path $root ($relative -replace "/", [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $source)) {
            throw "Runtime file not found: $relative"
        }

        $target = Join-Path $stagingRoot ($relative -replace "/", [System.IO.Path]::DirectorySeparatorChar)
        $targetDirectory = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $targetDirectory)) {
            New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
        }
        Copy-Item -LiteralPath $source -Destination $target -Force
    }

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    Compress-Archive -Path $stagingRoot -DestinationPath $zipPath -Force

    [pscustomobject]@{
        Addon = $addon.name
        Version = $addon.version
        ZipPath = $zipPath
        RootFolder = $package.rootFolderName
        FileCount = $files.Count
        Files = $files
    } | ConvertTo-Json -Depth 4
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
