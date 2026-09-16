<#
.SYNOPSIS
    WPS Tool Suite - Giao dieu console chon cong cu bang phim Up/Down hoac so.
    Chay: powershell -ExecutionPolicy Bypass -File WPS-ToolSuite.ps1
#>

$ErrorActionPreference = 'Stop'

# --- Luon luu file o Documents\tool_quet_ban_quyen ---
$scriptPath = Join-Path $env:USERPROFILE 'Documents\tool_quet_ban_quyen'
if (-not (Test-Path $scriptPath)) { New-Item -ItemType Directory -Path $scriptPath -Force | Out-Null }
Set-Location $scriptPath

$repoBase = 'https://raw.githubusercontent.com/laogiabacty/tool_wps/main'

# --- Ham tai file tu GitHub ---
function Download-File($relPath) {
    $dest = Join-Path $scriptPath $relPath
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    # Dung .Replace thay -replace de tranh loi regex
    $url = $repoBase + '/' + $relPath.Replace('\', '/')
    Write-Host "  [+] Dang tai: $relPath..." -ForegroundColor Yellow
    for ($i=1; $i -le 3; $i++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop
            Write-Host "  [+] Tai xong: $relPath" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "  [!] Lan $i that bai: $_" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    Write-Host "  [-] THAT BAI: $relPath" -ForegroundColor Red
    return $false
}

# --- Danh sach cong cu ---
$tools = @(
    @{ Name = "check_thong_tin.bat";                File = "check_thong_tin.bat";                Desc = "Kiem tra cau hinh may tinh" },
    @{ Name = "wps_quet_ban_quyen_thong_tin.bat";   File = "wps_quet ban quyen_thong tin.bat"; Desc = "Tu dong hoa quy trinh ho tro WPS" },
    @{ Name = "Cai_WPS_Cho_win10.ps1";              File = "Cai_WPS_Cho_win10.ps1";            Desc = "Cai WPS Office moi + Active VBA (Win 10)" },
    @{ Name = "Cai_WPS_Cho_win11.ps1";              File = "Cai_WPS_Cho_win11.ps1";            Desc = "Cai WPS Office moi + Active VBA (Win 11)" },
    @{ Name = "Uninstall-WPSOffice.ps1";            File = "Uninstall-WPSOffice.ps1";          Desc = "Go bo WPS Office" },
    @{ Name = "block_WPS/Chay-Block-WPS.bat";       File = "block_WPS\Chay-Block-WPS.bat";     Desc = "Chan ket noi Internet cua WPS" }
)

# --- Ham ve menu ---
function Show-Menu($tools, $selected) {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor DarkCyan
    Write-Host "   WPS TOOL SUITE - Quan ly tat ca cong cu" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor DarkCyan
    Write-Host "   Phim Up/Down: di chuyen   |   Enter: chay   |   0: thoat" -ForegroundColor DarkGray
    Write-Host ""
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $t = $tools[$i]
        $num = ($i + 1).ToString()
        if ($i -eq $selected) {
            Write-Host "  > [$num] $($t.Desc)" -ForegroundColor Black -BackgroundColor Cyan
        } else {
            Write-Host "    [$num] $($t.Desc)" -ForegroundColor White
        }
    }
    Write-Host ""
}

# --- Doc phim ---
function Read-MenuSelection($tools) {
    $selected = 0
    while ($true) {
        Show-Menu $tools $selected
        $key = $Host.UI.RawUI.Readkey("NoEcho,IncludeKeyDown")
        if ($key -eq $null) { continue }
        $vk = $key.VirtualKeyCode
        switch ($vk) {
            38 { if ($selected -gt 0) { $selected-- } }
            40 { if ($selected -lt $tools.Count - 1) { $selected++ } }
            13 { return $selected }
            48 { return -1 }
            default {
                $n = [int]($key.Character -replace '\D','')
                if ($n -ge 1 -and $n -le $tools.Count) { return ($n - 1) }
            }
        }
    }
}

# --- Chay cong cu (tu tai file neu thieu) ---
function Invoke-Tool($t) {
    $full = Join-Path $scriptPath $t.File
    Write-Host ""
    Write-Host "=== CHAY: $($t.File) ===" -ForegroundColor Yellow
    if (-not (Test-Path $full)) {
        Write-Host "[!] File chua co, dang tai tu GitHub..." -ForegroundColor Yellow
        if (-not (Download-File $t.File)) { return }
    }
    try {
        if ($t.File -match '\.ps1$') {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$full`"" -Wait -WindowStyle Normal
        } else {
            Start-Process cmd.exe -ArgumentList "/c `"$full`"" -Wait -WindowStyle Normal
        }
        Write-Host "[OK] Thuc hien xong: $($t.File)" -ForegroundColor Green
    } catch {
        Write-Host "[LOI] $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Main loop ---
while ($true) {
    $sel = Read-MenuSelection $tools
    if ($sel -eq -1) { Write-Host "Tam biet." -ForegroundColor DarkGray; exit }
    Invoke-Tool $tools[$sel]
    Write-Host ""
    Write-Host "Nhan Enter de quay lai menu..." -ForegroundColor DarkGray
    [void]($Host.UI.RawUI.Readkey("NoEcho,IncludeKeyDown"))
}
