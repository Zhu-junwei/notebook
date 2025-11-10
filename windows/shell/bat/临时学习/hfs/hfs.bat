@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

if "%1" neq "runas" mshta vbscript:CreateObject("Shell.Application").ShellExecute("conhost.exe","cmd.exe /c ""%~f0"" runas %*","","",1)(window.close)&&exit
shift && cd /d "%~dp0"

rem 设置 HFS 可执行文件的路径 
set HFS_PATH="hfs.exe"
set HFS_NAME=hfs.exe
set port=8068
set SHORTCUT_NAME="hfs.lnk"

:main
cls
mode con cols=70 lines=22
title hfs管理工具
echo 			hfs管理工具
echo.
echo				1.开启 
echo				2.关闭 
echo				3.状态 
echo				4.打开管理端 
echo				5.打开前端 
echo				6.添加开机启动 
echo				7.删除开机启动 
echo				8.退出 
echo.
set "choice="
set /p choice=请输入您的选择：

if "%choice%"=="1" goto start_hfs
if "%choice%"=="2" goto stop_hfs
if "%choice%"=="3" goto check_status
if "%choice%"=="4" goto start_admin
if "%choice%"=="5" goto start_front-end
if "%choice%"=="6" goto add_startup
if "%choice%"=="7" goto del_startup
if "%choice%"=="8" goto exit

goto main

:start_hfs
echo 启动 HFS... 
cscript //nologo hfs_start.vbs %port%
echo HFS 已启动。 & timeout /t 3
goto main

:stop_hfs
echo 停止 HFS... 
taskkill /F /IM %HFS_NAME% >nul 2>&1
echo HFS 已停止。 & timeout /t 3
goto main

:check_status
tasklist /FI "IMAGENAME eq %HFS_NAME%" 2>NUL | find /I "%HFS_NAME%" >nul
if errorlevel 1 (
    echo HFS 没有运行。
) else (
    echo HFS 正在运行。
)
timeout /t 3
goto main

:start_admin
start "" "http://localhost:%port%/~/admin/"
goto main

:start_front-end
start "" "http://localhost:%port%"
goto main

:add_startup
echo 正在创建开机启动快捷方式...
set "target=%~dp0%HFS_NAME%"
set "startup_folder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

rem 使用 PowerShell 创建快捷方式
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%startup_folder%\\%SHORTCUT_NAME%'); $s.TargetPath = '%target%'; $s.WorkingDirectory = '%~dp0'; $s.Save()"

if exist "%startup_folder%\%SHORTCUT_NAME%" (
    echo 已成功添加开机启动！
) else (
    echo 添加开机启动失败！
)
timeout /t 3
goto main

:del_startup
echo 正在删除开机启动快捷方式...
set "startup_folder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

if exist "%startup_folder%\%SHORTCUT_NAME%" (
    del "%startup_folder%\%SHORTCUT_NAME%"
    echo 已删除开机启动！
) else (
    echo 未找到开机启动快捷方式！
)
timeout /t 3
goto main
