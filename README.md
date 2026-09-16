# WPS Tool Suite - Quy trinh quan ly WPS Office tu 1 dong PowerShell

## Mo ta
Bo giao dieu (GUI) dieu khien tat ca cong cu WPS trong thu muc, thay vi chay tung file le.

## Chay nhanh (sau khi da push len GitHub)
```powershell
iex (iwr "https://raw.githubusercontent.com/ThaiVG/tool_quet_ban_quyen/main/Launcher.ps1")
```
Hoac:
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (Invoke-WebRequest 'https://raw.githubusercontent.com/ThaiVG/tool_quet_ban_quyen/main/Launcher.ps1')"
```

## Cac file chinh
| File | Chuc nang |
|------|-----------|
| `WPS-ToolSuite.ps1` | Giao dieu GUI - chon cong cu va chay |
| `Launcher.ps1` | Tai tuong tu GitHub + mo GUI |
| `Run-ToolSuite.bat` | Chay nhanh tu dia phan (co cap nhat tu GitHub) |
| `check_thong_tin.bat` | Kiem tra cau hinh may tinh |
| `wps_quet ban quyen_thong tin.bat` | Tu dong hoa quy trinh ho tro WPS |
| `Cai_WPS_Cho_win10.ps1` | Cai dat WPS Office moi + Active VBA (Win 10) |
| `Cai_WPS_Cho_win11.ps1` | Cai dat WPS Office moi + Active VBA (Win 11) |
| `Uninstall-WPSOffice.ps1` | Go bo WPS Office |
| `block_WPS/Chay-Block-WPS.bat` | Chan ket noi Internet cua WPS |

## Huong dan push len GitHub
1. Tao repo moi tren GitHub (ten: `tool_quet_ban_quyen`)
2. Push cac file:
```bash
git init
git add .
git commit -m "Add WPS Tool Suite - GUI launcher"
git remote add origin https://github.com/ThaiVG/tool_quet_ban_quyen.git
git push -u origin main
```
3. Sau khi push, chi can chay 1 dong:
```powershell
iex (iwr "https://raw.githubusercontent.com/ThaiVG/tool_quet_ban_quyen/main/Launcher.ps1")
```
