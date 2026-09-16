param(
    [ValidateSet('Scan','Block','Unblock','Status')][string]$Mode,
    [ValidateSet('Telemetry','All')][string]$Scope = 'Telemetry'
)

$Grp = 'WPS-Outbound-Block'

$Telemetry = @(
    'wpsupdate.exe','wpsupdatemgr.exe','wpsupdatesvr.exe','kwpsupdate.exe',
    'wpscloudsvr.exe','wpscenter.exe','wpsnotify.exe','wpsoffice.exe',
    'ksolaunch.exe','ksomisc.exe','kingsoftlivemsg.exe','promecefpluginhost.exe',
    'wpscloudlaunch.exe','wpsupdatemonitor.exe','wpsdocreport.exe','kmupdater.exe'
)

$Roots = @(
    "$env:LOCALAPPDATA\Kingsoft",
    "$env:ProgramFiles\Kingsoft",
    "${env:ProgramFiles(x86)}\Kingsoft",
    "$env:ProgramFiles\WPS Office",
    "${env:ProgramFiles(x86)}\WPS Office",
    "$env:ProgramData\Kingsoft"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique

function Get-Exes {
    $all = foreach ($r in $Roots) {
        Get-ChildItem -LiteralPath $r -Filter *.exe -Recurse -File -ErrorAction SilentlyContinue
    }
    $all = $all | Sort-Object FullName -Unique
    if ($Scope -eq 'All') { $all } else { $all | Where-Object { $Telemetry -contains $_.Name.ToLower() } }
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Pause-Enter($msg = 'Nhan ENTER de dong cua so...') {
    Write-Host ''
    Write-Host $msg -ForegroundColor DarkGray
    [void](Read-Host)
}

# ---------------------------------------------------------------------------
function Invoke-Task([string]$m) {

  try {
    switch ($m) {

    'Scan' {
        Write-Host "`n--- EXE se bi chan (Scope=$Scope) ---" -ForegroundColor Cyan
        $e = Get-Exes
        if (-not $e) {
            Write-Host 'Khong tim thay WPS trong cac thu muc quen thuoc.' -ForegroundColor Yellow
        } else {
            $e | Select-Object Name, FullName | Format-Table -AutoSize | Out-Host
            Write-Host "Tong: $($e.Count) file" -ForegroundColor Green
        }

        Write-Host "`n--- Ket noi Internet dang mo cua WPS ---" -ForegroundColor Cyan
        $map = @{}
        Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
            try { if ($_.Path -match 'Kingsoft|WPS Office') { $map[[int]$_.Id] = $_ } } catch {}
        }
        if ($map.Count -eq 0) {
            Write-Host 'Khong co tien trinh WPS nao dang chay.' -ForegroundColor Yellow
            Write-Host 'Meo: mo WPS len, doi ~30 giay roi quet lai.' -ForegroundColor DarkGray
            return
        }

        $rows = Get-NetTCPConnection -ErrorAction SilentlyContinue |
            Where-Object { $map.ContainsKey([int]$_.OwningProcess) -and $_.RemoteAddress -notin '0.0.0.0','::','127.0.0.1','::1' } |
            ForEach-Object {
                $dns = try { [System.Net.Dns]::GetHostEntry($_.RemoteAddress).HostName } catch { '-' }
                [pscustomobject]@{
                    Process = $map[[int]$_.OwningProcess].ProcessName
                    Remote  = $_.RemoteAddress
                    Port    = $_.RemotePort
                    Domain  = $dns
                }
            }
        if ($rows) { $rows | Format-Table -AutoSize | Out-Host }
        else { Write-Host 'Khong bat duoc ket noi nao ngay luc nay.' -ForegroundColor DarkGray }
    }

    'Block' {
        if (-not (Test-Admin)) { Write-Host 'Can quyen Administrator! Mo lai bang "Run as administrator".' -ForegroundColor Red; return }
        $exes = Get-Exes
        if (-not $exes) { Write-Host 'Khong tim thay exe nao de chan.' -ForegroundColor Yellow; return }

        if ($Scope -eq 'All') {
            Write-Host 'CANH BAO: Scope=All chan ca wps.exe/et.exe/wpp.exe.' -ForegroundColor Red
            Write-Host 'Se mat dang nhap tai khoan, WPS Cloud, template online.' -ForegroundColor Red
            if ((Read-Host 'Tiep tuc? (y/N)') -ne 'y') { Write-Host 'Da huy.'; return }
        }

        $n = 0; $skip = 0
        foreach ($x in $exes) {
            $rn = "WPS Block Out - $($x.Name) - $([Math]::Abs($x.FullName.GetHashCode()))"
            if (Get-NetFirewallRule -DisplayName $rn -ErrorAction SilentlyContinue) { $skip++; continue }
            New-NetFirewallRule -DisplayName $rn -Group $Grp -Direction Outbound `
                -Program $x.FullName -Action Block -Profile Any -Enabled True | Out-Null
            Write-Host "  [+] $($x.Name)" -ForegroundColor Green; $n++
        }
        Write-Host "`nDa tao $n rule moi, bo qua $skip rule da co." -ForegroundColor Cyan
    }

    'Unblock' {
        if (-not (Test-Admin)) { Write-Host 'Can quyen Administrator!' -ForegroundColor Red; return }
        $r = Get-NetFirewallRule -Group $Grp -ErrorAction SilentlyContinue
        if (-not $r) { Write-Host 'Khong co rule nao de xoa.' -ForegroundColor Yellow; return }
        $r | Remove-NetFirewallRule
        Write-Host "Da xoa $($r.Count) rule. WPS ket noi Internet binh thuong tro lai." -ForegroundColor Green
    }

    'Status' {
        $r = Get-NetFirewallRule -Group $Grp -ErrorAction SilentlyContinue
        if (-not $r) { Write-Host 'Chua co rule nao dang ap dung.' -ForegroundColor Yellow; return }
        $r | ForEach-Object {
            [pscustomobject]@{ Bat = $_.Enabled; Program = ($_ | Get-NetFirewallApplicationFilter).Program }
        } | Format-Table -AutoSize -Wrap | Out-Host
        Write-Host "Tong: $($r.Count) rule" -ForegroundColor Cyan
    }

    }
  }
  catch {
    Write-Host "`nLOI: $($_.Exception.Message)" -ForegroundColor Red
  }
}

# ---------------------------------------------------------------------------
# Chay 1 lan neu co tham so -Mode; nguoc lai hien menu.
# ---------------------------------------------------------------------------
if ($PSBoundParameters.ContainsKey('Mode')) {
    Invoke-Task $Mode
    Pause-Enter
    return
}

while ($true) {
    Write-Host ''
    Write-Host '==================================================' -ForegroundColor DarkCyan
    Write-Host '   CHAN KET NOI INTERNET CUA WPS OFFICE' -ForegroundColor Cyan
    Write-Host '==================================================' -ForegroundColor DarkCyan
    $adminTxt = if (Test-Admin) { 'Administrator: CO' } else { 'Administrator: KHONG (can cho muc 2 va 3)' }
    Write-Host "   $adminTxt   |   Scope: $Scope" -ForegroundColor DarkGray
    Write-Host ''
    Write-Host '   1. Quet   - xem exe nao cua WPS dang ra Internet'
    Write-Host '   2. Chan   - tao firewall rule chan theo tung exe'
    Write-Host '   3. Go chan- xoa het rule da tao'
    Write-Host '   4. Trang thai - xem rule dang co'
    Write-Host '   5. Doi Scope (Telemetry <-> All)'
    Write-Host '   0. Thoat'
    Write-Host ''
    $c = Read-Host '   Chon'

    switch ($c) {
        '1' { Invoke-Task 'Scan';    Pause-Enter 'Nhan ENTER de ve menu...' }
        '2' { Invoke-Task 'Block';   Pause-Enter 'Nhan ENTER de ve menu...' }
        '3' { Invoke-Task 'Unblock'; Pause-Enter 'Nhan ENTER de ve menu...' }
        '4' { Invoke-Task 'Status';  Pause-Enter 'Nhan ENTER de ve menu...' }
        '5' {
            $Scope = if ($Scope -eq 'Telemetry') { 'All' } else { 'Telemetry' }
            Write-Host "   Scope hien tai: $Scope" -ForegroundColor Yellow
        }
        '0' { Write-Host ''; Write-Host '   Tam biet.' -ForegroundColor DarkGray; Pause-Enter; return }
        default { Write-Host '   Lua chon khong hop le.' -ForegroundColor Red }
    }
}
