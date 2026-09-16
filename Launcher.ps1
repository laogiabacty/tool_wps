<#
.SYNOPSIS
    WPS Tool Suite - Chay bang 1 dong PowerShell tu bat ky may tinh.
    Chi can: iex (iwr "https://raw.githubusercontent.com/laogiabacty/tool_wps/main/Launcher.ps1")
#>
$ErrorActionPreference = 'Stop'
$repoBase = 'https://raw.githubusercontent.com/laogiabacty/tool_wps/main'
$localDir = Join-Path $env:USERPROFILE 'Documents\tool_quet_ban_quyen'
if (-not (Test-Path $localDir)) { New-Item -ItemType Directory -Path $localDir -Force | Out-Null }
Set-Location $localDir

# --- Tai cac file can thiet ---
$files = @(
    'WPS-ToolSuite.ps1',
    'check_thong_tin.bat',
    'wps_quet ban quyen_thong tin.bat',
    'Cai_WPS_Cho_win10.ps1',
    'Cai_WPS_Cho_win11.ps1',
    'Uninstall-WPSOffice.ps1',
    'block_WPS\Chay-Block-WPS.bat',
    'WPSOffice-12-2-0-22549.exe',
    'WPS.zip'
)
Write-Host "[Launcher] Dang tai file tu GitHub..." -ForegroundColor Cyan
foreach ($f in $files) {
    $dest = Join-Path $localDir $f
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    if (-not (Test-Path $dest)) {
        try {
            Invoke-WebRequest -Uri "$repoBase/$($f -replace '\','/')" -OutFile $dest -UseBasicParsing -ErrorAction SilentlyContinue
            Write-Host "  [+] Tai: $f" -ForegroundColor DarkGray
        } catch { Write-Host "  [-] Khong tai: $f" -ForegroundColor DarkGray }
    }
}

# --- Tai WPS-ToolSuite.ps1 neu chua co ---
$guiScript = Join-Path $localDir 'WPS-ToolSuite.ps1'
if (-not (Test-Path $guiScript)) {
    try {
        Invoke-WebRequest -Uri "$repoBase/WPS-ToolSuite.ps1" -OutFile $guiScript -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "[LOI] Khong tai duoc WPS-ToolSuite.ps1!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "[Launcher] Dang mo menu..." -ForegroundColor Cyan
powershell -NoProfile -ExecutionPolicy Bypass -File $guiScript
