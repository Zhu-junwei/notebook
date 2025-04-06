@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: 检查是否以管理员权限运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请以管理员权限运行此脚本！
    pause
    exit
)

echo =========================================
echo 正在重新安装 OneDrive...
if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    "%SystemRoot%\System32\OneDriveSetup.exe"
) else if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe"
) else (
    echo 找不到 OneDrive 安装程序，请手动下载安装！
    start https://go.microsoft.com/fwlink/p/?LinkID=2195324
    pause
    exit
)

timeout /t 5 /nobreak >nul

echo 安装完成，请重启计算机后使用 OneDrive！
pause
