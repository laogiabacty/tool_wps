# ==============================================================================
# Script: Gỡ bỏ WPS Office tự động
# Thư ký: An 🌸
# ==============================================================================

# 1. Kiểm tra và yêu cầu quyền Administrator (Quyền Quản trị viên)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️ Em cần quyền Administrator để gỡ ứng dụng. Đang khởi động lại PowerShell dưới quyền Admin..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "🚀 Đang tiến hành kiểm tra và gỡ bỏ WPS Office..." -ForegroundColor Cyan

# 2. Tắt các tiến trình ngầm của WPS Office nếu đang chạy
$wpsProcesses = @("wps", "wpp", "et", "wpscenter", "wpscloud", "kpageing", "wpsupdate")
foreach ($proc in $wpsProcesses) {
    $runningProc = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($runningProc) {
        Write-Host "🛑 Đang tắt tiến trình $proc..." -ForegroundColor Yellow
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }
}

# 3. Định nghĩa đường dẫn Registry để tìm WPS Office
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

$found = $false

# 4. Tìm và gọi trình gỡ cài đặt của WPS Office
foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            $displayName = (Get-ItemProperty -Path $_.PSPath).DisplayName
            $uninstallString = (Get-ItemProperty -Path $_.PSPath).UninstallString

            if ($displayName -and ($displayName -like "*WPS Office*" -or $displayName -like "*Kingsoft Office*")) {
                $found = $true
                Write-Host "📌 Đã tìm thấy: $displayName" -ForegroundColor Green
                
                if ($uninstallString) {
                    Write-Host "⏳ Đang tự động gỡ bỏ, anh đợi em chút nhé..." -ForegroundColor Cyan
                    
                    # Xử lý chuỗi UninstallString để chạy lệnh gỡ ẩn (Silent)
                    if ($uninstallString -match 'uninst\.exe') {
                        # Nếu dùng uninst.exe của WPS, thêm tham số -s để gỡ âm thầm
                        $exe = ($uninstallString -split '(?<=\.exe)')[0].Replace('"', '').Trim()
                        Start-Process -FilePath $exe -ArgumentList "-s" -Wait -WindowStyle Hidden
                    } else {
                        # Trường hợp khác (MsiExec...)
                        Start-Process cmd.exe -ArgumentList "/c $uninstallString /quiet /norestart" -Wait -WindowStyle Hidden
                    }
                    
                    Write-Host "✅ Đã gỡ xong $displayName thành công!" -ForegroundColor Green
                }
            }
        }
    }
}

if (-not $found) {
    Write-Host "🔍 Em đã tìm khắp máy nhưng không thấy phần mềm WPS Office nào được cài đặt cả anh ơi!" -ForegroundColor Yellow
} else {
    Write-Host "🎉 Mọi việc đã xong xuôi! Máy tính của anh đã sạch sẽ WPS Office rồi ạ." -ForegroundColor Green
}