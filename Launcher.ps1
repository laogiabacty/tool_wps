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

# --- Tai tat ca file can thiet ---
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
    # Dung .Replace thay -replace de tranh loi regex
    $url = "$repoBase/" + $f.Replace('\', '/')
    $ok = $false
    for ($i=1; $i -le 3; $i++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop
            $ok = $true
            Write-Host "  [+] Tai: $f" -ForegroundColor Green
            break
        } catch {
            Write-Host "  [!] Lan $i that bai: $f - $_" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    if (-not $ok) { Write-Host "  [-] THAT BAI: $f" -ForegroundColor Red }
}

Write-Host "[Launcher] Dang mo menu..." -ForegroundColor Cyan
$guiScript = Join-Path $localDir 'WPS-ToolSuite.ps1'
powershell -NoProfile -ExecutionPolicy Bypass -File $guiScript
