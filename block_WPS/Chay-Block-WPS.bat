@echo off
title Chan Internet cua WPS Office
cd /d "%~dp0"

:: Tu xin quyen Administrator neu chua co
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Dang xin quyen Administrator...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Block-WPS.ps1"

echo.
echo Cua so se dong khi ban nhan phim bat ky.
pause >nul
