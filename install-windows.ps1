# Installs (or updates) the Sacid plug-ins you pick on Windows: plug-ins into
# C:\Program Files\Common Files\VST3, the standalone apps into C:\Program Files\Sacid with
# Start menu shortcuts. Asks which ones, then for administrator rights.
#   irm https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-windows.ps1 | iex
# Unattended: $env:SACID_ONLY = 'SacidOne SacidHalo' (or $env:SACID_ANSWER = '1 5') skips the question.
$ErrorActionPreference = 'Stop'
$script = 'https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-windows.ps1'
$repo = if ($env:SACID_REPO) { $env:SACID_REPO } else { 'https://github.com/aleksandrsvoboda/sacid-plugins/releases/download' }
$vst3 = if ($env:SACID_DEST) { $env:SACID_DEST } else { Join-Path $env:CommonProgramFiles 'VST3' }
$apps = if ($env:SACID_APPS) { $env:SACID_APPS } else { Join-Path $env:ProgramFiles 'Sacid' }

# Name, release tag, earlier names (removed when that plug-in is installed), description.
$catalogue = @(
    @{ Name = 'SacidOne';     Tag = 'sacidone-1.2';     Old = @('AcidOne', 'SacedOne'); Desc = 'mono synth: analog / FM / granular + step sequencer' },
    @{ Name = 'SacidSampler'; Tag = 'sacidsampler-1.1'; Old = @('AcidSampler');         Desc = 'pitch-tracking sampler' },
    @{ Name = 'SacidKit';     Tag = 'sacidkit-1.1';     Old = @('AcidKit');             Desc = '808 / 909 drum machine' },
    @{ Name = 'Sacid303';     Tag = 'sacid303-2.1';     Old = @('Acid303');             Desc = '303 bass synth + sequencer' },
    @{ Name = 'SacidHalo';    Tag = 'sacidhalo-1.0';    Old = @();                      Desc = 'harmonic exciter + reverb (effect)' }
)

# --- Pick which ones (before asking for administrator rights) ---------------------------
if ($env:SACID_ONLY) {
    $selected = @($env:SACID_ONLY -split '[,\s]+' | Where-Object { $_ })
} else {
    Write-Host ''
    Write-Host 'Sacid plug-ins:'
    for ($i = 0; $i -lt $catalogue.Count; $i++) {
        $c = $catalogue[$i]
        $mark = if (Test-Path (Join-Path $vst3 ($c.Name + '.vst3'))) { '  [installed]' } else { '' }
        Write-Host ('  {0}) {1,-13} {2}{3}' -f ($i + 1), $c.Name, $c.Desc, $mark)
    }
    Write-Host ''
    while ($true) {
        $answer = if ($null -ne $env:SACID_ANSWER) { $env:SACID_ANSWER } else { Read-Host 'Which ones? Numbers like "1 3 5", Enter = all, q = quit' }
        $answer = ([string] $answer).Trim()
        if ($answer -match '^(q|quit)$') { Write-Host 'Nothing installed.'; return }
        if ($answer -eq '' -or $answer -match '^(a|all)$') { $selected = @($catalogue | ForEach-Object { $_.Name }); break }
        $numbers = @($answer -split '[,\s]+' | Where-Object { $_ })
        $valid = $numbers.Count -gt 0
        foreach ($n in $numbers) { if ($n -notmatch '^\d+$' -or [int] $n -lt 1 -or [int] $n -gt $catalogue.Count) { $valid = $false } }
        if ($valid) { $selected = @($numbers | ForEach-Object { $catalogue[[int] $_ - 1].Name } | Select-Object -Unique); break }
        Write-Host "  Please type numbers from 1 to $($catalogue.Count), separated by spaces (or press Enter for all)."
        if ($null -ne $env:SACID_ANSWER) { return }   # a scripted wrong answer would loop forever
    }
}
if ($selected.Count -eq 0) { Write-Host 'Nothing selected.'; return }
Write-Host ('Installing: ' + ($selected -join ' '))

# The system plug-in folder needs administrator rights: re-run elevated (one UAC prompt),
# passing the choice along so the new window doesn't ask again.
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin -and -not $env:SACID_DEST) {
    Write-Host 'Asking for administrator rights to install into the system VST3 folder...'
    $only = $selected -join ' '
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"`$env:SACID_ONLY='$only'; irm '$script' | iex`""
    return
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('sacid-' + [Guid]::NewGuid())
New-Item -ItemType Directory -Force $tmp, $vst3, $apps | Out-Null
$startMenu = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Sacid'

foreach ($c in $catalogue) {
    if ($selected -notcontains $c.Name) { continue }
    $name = $c.Name
    # Copies under earlier names are the same plug-in and would show up twice in Live.
    foreach ($old in $c.Old) {
        Remove-Item -Recurse -Force (Join-Path $vst3 "$old.vst3") -ErrorAction SilentlyContinue
        Remove-Item -Force (Join-Path $apps "$old.exe") -ErrorAction SilentlyContinue
    }
    $zip = Join-Path $tmp "$name.zip"
    try { Invoke-WebRequest -UseBasicParsing -Uri "$repo/$($c.Tag)/$name-win64.zip" -OutFile $zip }
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
