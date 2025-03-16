@echo off
:: 获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit cd /d "%~dp0"

:: 主菜单
:main_menu
cls
mode con cols=55 lines=20
title Windows管理小工具 v1.3
set "main_option="
echo *************************************
echo  1. Windows 11 右键菜单管理
echo  2. 桌面图标小箭头管理
echo  3. 卸载 Windows 11 小组件
echo  4. 安装 Office
echo  5. 激活 Windows ^& Office
echo  6. Windows更新管理
echo  7. Windows 10 此电脑文件夹管理
echo  0. 退出
echo *************************************
echo.
set /p main_option=请输入你的选择: 
if "%main_option%"=="" goto main_menu
echo.

if "%main_option%"=="1" goto submenu_right_click
if "%main_option%"=="2" goto submenu_arrow
if "%main_option%"=="3" goto uninstall_widgets
if "%main_option%"=="4" goto install_office
if "%main_option%"=="5" goto activate_windows
if "%main_option%"=="6" goto windows_update
if "%main_option%"=="7" goto this_computer_folder
if "%main_option%"=="0" goto byebye

goto main_menu

:: 右键菜单管理子菜单
:submenu_right_click
cls
title Windows 11 右键菜单管理
set "submenu_option="
echo *************************************
echo  1. 切换 Windows 10 右键菜单
echo  2. 恢复 Windows 11 右键菜单
echo  0. 返回主菜单
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="" goto submenu_right_click
echo.

if "%submenu_option%"=="1" ( 
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    taskkill /f /im explorer.exe & start explorer.exe
    goto submenu_right_click
) else if "%submenu_option%"=="2" ( 
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f 
    taskkill /f /im explorer.exe & start explorer.exe
    goto submenu_right_click
)  else if "%submenu_option%"=="0" goto main_menu

goto submenu_right_click

:: 桌面图标小箭头管理子菜单
:submenu_arrow
cls
title 桌面图标小箭头管理
set "submenu_option="
echo *************************************
echo  1. 隐藏桌面图标小箭头
echo  2. 显示桌面图标小箭头
echo  0. 返回主菜单
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="" goto submenu_arrow
echo.

if "%submenu_option%"=="1" (
    echo 正在隐藏桌面图标小箭头...
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f
    taskkill /f /im explorer.exe
    attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db" >nul 2>&1
    del "%userprofile%\AppData\Local\iconcache.db" /f /q >nul 2>&1
    start explorer
    echo 操作完成！
    pause
    goto submenu_arrow
) else if "%submenu_option%"=="2" (
    echo 正在显示桌面图标小箭头...
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
    taskkill /f /im explorer.exe
    attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db" >nul 2>&1
    del "%userprofile%\AppData\Local\iconcache.db" /f /q >nul 2>&1
    start explorer
    echo 操作完成！
    goto submenu_arrow
) else if "%submenu_option%"=="0" goto main_menu

goto submenu_arrow


:: 卸载 Windows 11 小组件
:uninstall_widgets
cls
title 卸载 Windows 11 小组件
winget uninstall MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy
taskkill /f /im explorer.exe & start explorer.exe
goto main_menu

:: 安装 Office
:install_office
cls
title 安装 Office
start powershell -NoProfile -ExecutionPolicy Bypass -Command "irm officetool.plus | iex"
goto main_menu

:: 激活 Windows & Office
:activate_windows
cls
title 激活 Windows & Office
start powershell -Command "irm https://get.activated.win | iex"
goto main_menu

@REM From https://www.52pojie.cn/thread-1791338-1-1.html
:: Windows更新管理
:windows_update
cls
title Windows更新管理
set "submenu_option="
echo *************************************
echo  1. 禁用Windows更新
echo  2. 启用Windows更新
echo  0. 返回主菜单
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="" goto windows_update
echo.

if "%submenu_option%"=="1" (
	echo 正在禁用系统更新...
	net stop wuauserv
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "PauseDeferrals" /t REG_DWORD /d "0x1" /f  >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ElevateNonAdmins" /t REG_DWORD /d "0x1" /f  >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d "0x1" /f  >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d "http://127.0.0.1" /f  >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d "http://127.0.0.1" /f  >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoWindowsUpdate" /t REG_DWORD /d "0x1" /f  >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "0x1" /f  >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AutoInstallMinorUpdates" /t REG_DWORD /d "0x1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DetectionFrequencyEnabled" /t REG_DWORD /d "0x0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "RescheduleWaitTimeEnabled" /t REG_DWORD /d "0x0" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d "0x1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "RescheduleWaitTimeEnabled" /t REG_DWORD /d "0x1" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\WAU" /v "Disabled" /t REG_DWORD /d "0x1" /f >nul 2>&1
	REG add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d 1 /f >nul 2>&1
	REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	REG add "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "ReservationsAllowed" /t REG_DWORD /d 0 /f >nul 2>&1
	REG add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx" /t REG_DWORD /d 1 /f >nul 2>&1
	REG add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\EOSNotify" /v "DiscontinueEOS" /t REG_DWORD /d 1 /f >nul 2>&1
	net start wuauserv
	echo 系统已禁止更新
	echo.
	pause
    goto windows_update
) else if "%submenu_option%"=="2" (
	echo 正在开启系统更新...
    net stop wuauserv
	REG delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start"  /f >nul 2>&1
	REG delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /v "Start"  /f >nul 2>&1
	REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	REG delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "ReservationsAllowed" /f >nul 2>&1
	REG delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx"  /f >nul 2>&1
	REG delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\EOSNotify" /v "DiscontinueEOS" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "PauseDeferrals" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ElevateNonAdmins" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer"  /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /f >nul 2>&1
	reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoWindowsUpdate" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AutoInstallMinorUpdates" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DetectionFrequencyEnabled" /f >nul 2>&1
	reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" /v "DisableWindowsUpdateAccess" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "RescheduleWaitTimeEnabled" /f >nul 2>&1
	reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\WAU" /v "Disabled" /f >nul 2>&1
	REG delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade"  /f >nul 2>&1
	net start wuauserv
	echo 系统已开启更新
	echo.
	pause
    goto windows_update
) else if "%submenu_option%"=="0" goto main_menu

goto windows_update

:: Windows 10 此电脑文件夹管理
:this_computer_folder
cls
title Windows 10 此电脑文件夹管理
set "submenu_option="
set "restart_explorer=false"
echo *************************************
echo  1. 隐藏 3D Objects
echo  2. 恢复 3D Objects
echo  3. 隐藏 视频
echo  4. 恢复 视频
echo  5. 隐藏 图片
echo  6. 恢复 图片
echo  7. 隐藏 文档
echo  8. 恢复 文档
echo  9. 隐藏 下载
echo  10. 恢复 下载
echo  11. 隐藏 音乐
echo  12. 恢复 音乐
echo  13. 隐藏 桌面
echo  14. 恢复 桌面
echo  15. 隐藏所有选项
echo  16. 开启所有选项
echo  0. 返回主菜单
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="" goto this_computer_folder
echo.

if "%submenu_option%"=="1" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="2" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="3" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="4" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="5" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="6" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="7" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="8" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="9" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="10" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="11" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="12" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="13" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="14" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="15" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	set "restart_explorer=true"
) else if "%submenu_option%"=="16" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	set "restart_explorer=true"
)  else if "%submenu_option%"=="0" goto main_menu
if "%restart_explorer%"=="true" (
    taskkill /f /im explorer.exe
    start explorer
)
goto this_computer_folder

:: 桌面图标小箭头管理子菜单
:submenu_arrow
cls
title 桌面图标小箭头管理
set "submenu_option="
echo *************************************
echo  1. 隐藏桌面图标小箭头
echo  2. 显示桌面图标小箭头
echo  0. 返回主菜单
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="" goto submenu_arrow
echo.

if "%submenu_option%"=="1" (
    echo 正在隐藏桌面图标小箭头...
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f
    taskkill /f /im explorer.exe
    attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db" >nul 2>&1
    del "%userprofile%\AppData\Local\iconcache.db" /f /q >nul 2>&1
    start explorer
    echo 操作完成！
    pause
    goto submenu_arrow
) else if "%submenu_option%"=="2" (
    echo 正在显示桌面图标小箭头...
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
    taskkill /f /im explorer.exe
    attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db" >nul 2>&1
    del "%userprofile%\AppData\Local\iconcache.db" /f /q >nul 2>&1
    start explorer
    echo 操作完成！
    goto submenu_arrow
) else if "%submenu_option%"=="0" goto main_menu

goto submenu_arrow

:byebye
echo byebye
ping -n 2 127.0.0.1 > nul
exit