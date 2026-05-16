param(
    [string] $Version,
    [int] $AddOnVersion,
    [switch] $Patch,
    [switch] $Check
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).ProviderPath
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text {
    param([string] $Path)
    return [System.IO.File]::ReadAllText($Path, $utf8)
}

function Write-Text {
    param([string] $Path, [string] $Content)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Get-RegexValue {
    param([string] $Content, [string] $Pattern)
    $match = [regex]::Match($Content, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}

function Set-RegexValue {
    param([string] $Content, [string] $Pattern, [string] $Value)
    return [regex]::Replace($Content, $Pattern, {
        param($match)
        return $match.Groups[1].Value + $Value + $match.Groups[2].Value
    }, [System.Text.RegularExpressions.RegexOptions]::Multiline)
}

function Increment-PatchVersion {
    param([string] $CurrentVersion)
    $parts = $CurrentVersion.Split(".")
    if ($parts.Count -ne 3) { throw "Cannot patch-bump non-semver version '$CurrentVersion'." }
    return "$($parts[0]).$($parts[1]).$([int]$parts[2] + 1)"
}

$manifest = Join-Path $root "EZOAlerts.txt"
$core = Join-Path $root "modules\core.lua"
$config = Join-Path $root "ezo-addon.json"

$manifestText = Read-Text $manifest
$coreText = Read-Text $core
$configText = Read-Text $config

$manifestVersion = Get-RegexValue $manifestText '^## Version:\s*(.+?)\s*$'
$manifestAddOnVersion = Get-RegexValue $manifestText '^## AddOnVersion:\s*(\d+)\s*$'
$coreVersion = Get-RegexValue $coreText '^\s*EZOAlerts\.ADDON_VERSION\s*=\s*"([^"]+)"\s*$'
$configVersion = Get-RegexValue $configText '"version":\s*"([^"]+)"'

if ($Check) {
    $ok = $true
    if ($manifestVersion -ne $coreVersion) {
        Write-Error "Version mismatch: EZOAlerts.txt=$manifestVersion modules/core.lua=$coreVersion"
        $ok = $false
    }
    if ($manifestVersion -ne $configVersion) {
        Write-Error "Version mismatch: EZOAlerts.txt=$manifestVersion ezo-addon.json=$configVersion"
        $ok = $false
    }
    if (-not $manifestAddOnVersion) {
        Write-Error "Missing ## AddOnVersion in EZOAlerts.txt"
        $ok = $false
    }
    if (-not $ok) { exit 1 }
    Write-Host "Version check OK: $manifestVersion / AddOnVersion $manifestAddOnVersion"
    exit 0
}

if ($Patch) {
    if ($Version) { throw "Use either -Patch or -Version, not both." }
    $Version = Increment-PatchVersion $manifestVersion
}

if (-not $Version) {
    throw "Pass -Version <x.y.z>, use -Patch, or use -Check."
}

if (-not $PSBoundParameters.ContainsKey("AddOnVersion")) {
    $AddOnVersion = [int]$manifestAddOnVersion + 1
}

$manifestText = Set-RegexValue $manifestText '^(## Version:\s*).+?(\s*)$' $Version
$manifestText = Set-RegexValue $manifestText '^(## AddOnVersion:\s*)\d+(\s*)$' ([string]$AddOnVersion)
$coreText = Set-RegexValue $coreText '^(\s*EZOAlerts\.ADDON_VERSION\s*=\s*")[^"]+("\s*)$' $Version
$configText = Set-RegexValue $configText '^(\s*"version":\s*")[^"]+(",\s*)$' $Version
$configText = Set-RegexValue $configText '^(\s*"zipName":\s*"EZOAlerts_v)[^"]+(\.zip",\s*)$' $Version

Write-Text $manifest $manifestText
Write-Text $core $coreText
Write-Text $config $configText

Write-Host "Version updated to $Version / AddOnVersion $AddOnVersion"
