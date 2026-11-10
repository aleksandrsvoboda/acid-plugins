# Installs (or updates) Sacid303, SacidKit, SacidSampler, SacidOne and SacidHalo on Windows:
# plug-ins into C:\Program Files\Common Files\VST3, the standalone apps into
# C:\Program Files\Sacid with Start menu shortcuts. Asks for administrator rights.
#   irm https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-windows.ps1 | iex
$ErrorActionPreference = 'Stop'
$script = 'https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-windows.ps1'
$repo = if ($env:SACID_REPO) { $env:SACID_REPO } else { 'https://github.com/aleksandrsvoboda/sacid-plugins/releases/download' }
$vst3 = if ($env:SACID_DEST) { $env:SACID_DEST } else { Join-Path $env:CommonProgramFiles 'VST3' }
$apps = if ($env:SACID_APPS) { $env:SACID_APPS } else { Join-Path $env:ProgramFiles 'Sacid' }
$plugins = @(@('Sacid303', 'sacid303-2.1'), @('SacidKit', 'sacidkit-1.1'), @('SacidSampler', 'sacidsampler-1.1'), @('SacidOne', 'sacidone-1.2'), @('SacidHalo', 'sacidhalo-1.0'))
$oldNames = 'Acid303', 'AcidKit', 'AcidSampler', 'AcidOne', 'SacedOne'

# The system plug-in folder needs administrator rights: re-run elevated (one UAC prompt).
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin -and -not $env:SACID_DEST) {
    Write-Host 'Asking for administrator rights to install into the system VST3 folder...'
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"irm '$script' | iex`""
    return
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('sacid-' + [Guid]::NewGuid())
New-Item -ItemType Directory -Force $tmp, $vst3, $apps | Out-Null

# The plug-ins were renamed; the old copies are the same plug-ins and would show up twice.
foreach ($old in $oldNames) { Remove-Item -Recurse -Force (Join-Path $vst3 "$old.vst3") -ErrorAction SilentlyContinue }

$startMenu = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Sacid'
foreach ($p in $plugins) {
    $name = $p[0]; $tag = $p[1]
    $zip = Join-Path $tmp "$name.zip"
    try { Invoke-WebRequest -UseBasicParsing -Uri "$repo/$tag/$name-win64.zip" -OutFile $zip }
    catch { Write-Host "  ${name}: download failed, skipped (try again in a few minutes)"; continue }
    $out = Join-Path $tmp $name
    Expand-Archive -Force $zip $out
    Get-ChildItem -Recurse $out | Unblock-File
    Remove-Item -Recurse -Force (Join-Path $vst3 "$name.vst3") -ErrorAction SilentlyContinue
    Copy-Item -Recurse (Join-Path $out "$name.vst3") $vst3
    $exe = Join-Path $out "$name.exe"
    if (Test-Path $exe) {
        Copy-Item -Force $exe $apps
        if (-not $env:SACID_DEST) {
            New-Item -ItemType Directory -Force $startMenu | Out-Null
            $link = (New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $startMenu "$name.lnk"))
            $link.TargetPath = Join-Path $apps "$name.exe"
            $link.Save()
        }
    }
    Write-Host "  ${name}: installed"
}
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
Write-Host ''
Write-Host "Done. Plug-ins are in $vst3. In Ableton Live: Settings > Plug-Ins, turn on"
Write-Host "'Use VST3 Plug-In System Folders' and press Rescan. They're under Plug-Ins > VST3 > Sacid."
Write-Host "The standalone apps are in the Start menu under Sacid."
