# Auto Self-Elevate to Administrator if not running as Admin (Compatible with Windows 11 Terminal)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Dang yeu cau quyen Administrator..." -ForegroundColor Yellow
    $psPath = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
    Start-Process $psPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Fix Vietnamese Encoding Display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Set current working directory
$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }
Set-Location $scriptPath

Clear-Host
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "     CHUONG TRINH TU DONG CAI DAT WPS OFFICE MOI + ACTIVE VBA (WIN 10/11)" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Thu muc lam viec: $scriptPath" -ForegroundColor Gray
Write-Host ""

# Define file paths
$wpsExe = Join-Path $scriptPath 'WPSOffice-12-2-0-22549.exe'
$wpsZip = Join-Path $scriptPath 'WPS.zip'

# Check required files before running
$missingFile = $false
if (-not (Test-Path $wpsExe)) {
    Write-Host "[LOI] Khong tim thay file: WPSOffice-12-2-0-22549.exe" -ForegroundColor Red
    $missingFile = $true
}
if (-not (Test-Path $wpsZip)) {
    Write-Host "[LOI] Khong tim thay file: WPS.zip" -ForegroundColor Red
    $missingFile = $true
}

if ($missingFile) {
    Write-Host ""
    Write-Host "Vui long dat file .ps1 nay CHUNG THU MUC voi 2 file tren va chay lai!" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Nhan Enter de thoat..."
    exit
}

# --- BƯỚC CÀI MỚI VÀ ACTIVE VBA ---
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "DANG CAI DAT BAN WPS OFFICE MOI VA ACTIVE VBA..." -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Write-Host "[-] Dang cai ngam WPS Office moi..." -ForegroundColor Yellow
$p = Start-Process -FilePath $wpsExe -ArgumentList '/S' -PassThru -ErrorAction SilentlyContinue

# Đợi installer chính thoát hẳn hoặc hết timeout 60s
$waitCount = 0
while (-not $p.HasExited -and $waitCount -lt 60) {
    Start-Sleep -Seconds 1
    $waitCount++
}

Write-Host "[-] Dang lam sach tat ca tien trinh WPS ngam truoc khi Active VBA..." -ForegroundColor Yellow

# Tắt sạch các tiến trình WPS, Installer, Auto-update đang chạy ngầm
Get-Process -Name "*wps*", "*kingsoft*", "*kso*", "*wpscenter*", "*wpsupdate*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4

Write-Host "[OK] Da cai dat xong WPS Office base." -ForegroundColor Green

# Giải nén trực tiếp ngay tại thư mục hiện tại
Write-Host "[-] Dang gia nen WPS.zip..." -ForegroundColor Yellow
Expand-Archive -Path $wpsZip -DestinationPath $scriptPath -Force

# Tìm kiếm file VBAxWPS.exe
$vbaExeFile = Get-ChildItem -Path $scriptPath -Filter "VBAxWPS.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($vbaExeFile) {
    $vbaDir = $vbaExeFile.DirectoryName
    Write-Host "[-] Tim thay file VBAxWPS.exe tai: $($vbaExeFile.FullName)" -ForegroundColor Green
    Write-Host "[-] Dang thuc thi va tu dong kich hoat VBA ngam..." -ForegroundColor Yellow
    
    Set-Location -Path $vbaDir
    
    # Chạy VBAxWPS
    $pvba = Start-Process -FilePath $vbaExeFile.FullName -ArgumentList "/S" -WorkingDirectory $vbaDir -PassThru -ErrorAction SilentlyContinue

    # Fallback tự động gửi phím nếu GUI hiện (Tương thích Windows 11)
    $wshell = New-Object -ComObject WScript.Shell
    $timeout = 0
    while (-not $pvba.HasExited -and $timeout -lt 40) {
        Start-Sleep -Milliseconds 500
        $timeout++

        if ($wshell.AppActivate("Visual Basic") -or $wshell.AppActivate("Setup") -or $wshell.AppActivate("VBA")) {
            Start-Sleep -Milliseconds 600
            $wshell.SendKeys("{ENTER}")
            Start-Sleep -Milliseconds 800
            $wshell.SendKeys("%a")
            Start-Sleep -Milliseconds 800
            $wshell.SendKeys("{ENTER}")
        }
    }

    if (-not $pvba.HasExited) { $pvba.WaitForExit() }
    
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wshell) | Out-Null
    
    Set-Location -Path $scriptPath
    Write-Host "[OK] ACTIVE VBA HOAN TAT!" -ForegroundColor Green
} else {
    Write-Host "[LOI] Khong tim thay file VBAxWPS.exe sau khi gia nen!" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "   DA HOAN THANH QUY TRINH CAI DAT & ACTIVATION TREN WIN 10/11!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Nhan Enter de thoat cua so..."