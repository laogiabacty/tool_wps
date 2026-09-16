@echo off
title He Thong Kiem Tra Cau Hinh May Tinh - P.CNTT
mode con: cols=90 lines=36

set "LOGFILE=%~dp0ThongTinMay.txt"

:: Dung PowerShell cu phap co dien de tuong thich PowerShell v5.1 tro len
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$name = (Get-CimInstance Win32_ComputerSystem).Name;" ^
    "$chassis = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes;" ^
    "$form = 'PC (Desktop)';" ^
    "foreach ($c in $chassis) { if ($c -eq 8 -or $c -eq 9 -or $c -eq 10 -or $c -eq 14) { $form = 'Laptop' } };" ^
    "$osName = (Get-CimInstance Win32_OperatingSystem).Caption;" ^
    "$osArch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture;" ^
    "$osInstall = (Get-CimInstance Win32_OperatingSystem).InstallDate;" ^
    "$osInstallStr = Get-Date $osInstall -Format 'dd/MM/yyyy';" ^
    "$serial = (Get-CimInstance Win32_Bios).SerialNumber;" ^
    "$cpu = (Get-CimInstance Win32_Processor).Name;" ^
    "$ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory;" ^
    "$ram = [math]::Round($ramBytes / 1024 / 1024 / 1024);" ^
    "if ($ram -eq 0) { $ram = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB) };" ^
    "$mainMfg = (Get-CimInstance Win32_BaseBoard).Manufacturer;" ^
    "$mainModel = (Get-CimInstance Win32_BaseBoard).Product;" ^
    "$isDomain = (Get-CimInstance Win32_ComputerSystem).PartOfDomain;" ^
    "$domainName = (Get-CimInstance Win32_ComputerSystem).Domain;" ^
    "   " ^
    "$log = @();" ^
    "$log += '========================================================';" ^
    "$log += '                 THONG TIN CAU HINH MAY TINH            ';" ^
    "$log += '========================================================';" ^
    "$log += 'Ngay kiem tra: ' + (Get-Date -Format 'dd/MM/yyyy HH:mm:ss');" ^
    "$log += '--------------------------------------------------------';" ^
    "$log += '[1] Ten may: ' + $name;" ^
    "$log += '[2] Loai may: ' + $form;" ^
    "$log += '[3] Phien ban Windows: ' + $osName + ' (' + $osArch + ')';" ^
    "$log += '    - Ngay cai dat Windows: ' + $osInstallStr;" ^
    "$log += '[4] So Serial: ' + $serial;" ^
    "$log += '[5] CPU: ' + $cpu;" ^
    "$log += '[6] Tong dung luong RAM: ' + $ram + ' GB';" ^
    "$log += '[7] Mainboard: ' + $mainMfg + ' ' + $mainModel;" ^
    "if ($isDomain) {" ^
    "   $log += '[8] Trang thai mang: DA THAM GIA DOMAIN (' + $domainName + ')';" ^
    "   $log += '    User Domain dang dang nhap: ' + $env:USERNAME;" ^
    "} else {" ^
    "   $log += '[8] Trang thai mang: Workgroup (Khong len Domain)';" ^
    "}" ^
    "$log += '[9] Danh sach o cung phat hien tren may:';" ^
    "   " ^
    "$disks = Get-CimInstance Win32_DiskDrive;" ^
    "$i = 1;" ^
    "foreach ($d in $disks) {" ^
    "   $dSize = [math]::Round($d.Size / 1GB);" ^
    "   if ($dSize -eq 0) { $dSize = [math]::Round($d.Size / 1000000000) };" ^
    "   $log += '   + O ' + $i + ': Model: ' + $d.Model + ' - Dung luong: ' + $dSize + ' GB';" ^
    "   $i++;" ^
    "};" ^
    "$log += '--------------------------------------------------------';" ^
    "   " ^
    "Clear-Host;" ^
    "Write-Host '========================================================';" ^
    "Write-Host '         HE THONG KIEM TRA CAU HINH MAY TINH - P.CNTT';" ^
    "Write-Host '========================================================';" ^
    "Write-Host '';" ^
    "foreach ($line in $log) {" ^
    "   if ($line -match '^===' -or $line -match '^---') { continue };" ^
    "   Write-Host $line;" ^
    "}" ^
    "Write-Host '';" ^
    "Write-Host '========================================================';" ^
    "Write-Host '';" ^
    "Write-Host 'LUU Y: File bao cao chi tiet da duoc xuat ra o: ThongTinMay.txt';" ^
    "Write-Host '';" ^
    "$log | Out-File -FilePath '%LOGFILE%' -Encoding utf8"

pause