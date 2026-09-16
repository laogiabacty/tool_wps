@echo off
title WPS Tool Suite - Tu dong cap nhat va chay
setlocal

set "REPO_URL=https://raw.githubusercontent.com/ThaiVG/tool_quet_ban_quyen/main"
set "LOCAL_DIR=%~dp0"
set "SCRIPT=WPS-ToolSuite.ps1"

echo [1/3] Dang kiem tra cap nhat tu GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$url='%REPO_URL%/%SCRIPT%'; $dest=Join-Path '%LOCAL_DIR%' '%SCRIPT%'; ^
     try { ^
         Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop; ^
         Write-Host '[OK] Da cap nhat tu GitHub.' -ForegroundColor Green ^
     } catch { ^
         if (Test-Path $dest) { Write-Host '[WARN] Khong cap nhat duoc, dung phien ban cu.' -ForegroundColor Yellow } ^
         else { Write-Host '[LOI] Khong co file local va khong tai ve duoc!' -ForegroundColor Red; exit 1 } ^
     }"

echo [2/3] Dang mo giao dieu...
powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCAL_DIR%%SCRIPT%"

echo [3/3] Hoan tat.
