@echo off
:: 获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit cd /d "%~dp0"

:: 背景和字体颜色，窗口大小
color 0A
mode con cols=55 lines=20

:: 主菜单
:main_menu
title Windows管理小工具 v1.4 & cls
set "main_option="
echo *************************************
echo   1. 右键菜单设置
echo   2. 桌面设置
echo   3. 任务栏设置
echo   4. 资源管理器设置
echo   5. 安装 Office
echo   6. 激活 Windows ^& Office
echo   7. Windows更新设置
echo   8. UAC（用户账户控制）设置
echo   9. 上帝模式
echo   0. 退出
echo *************************************
echo.
set /p main_option=请输入你的选择: 
if "%main_option%"=="1" call :submenu_right_click
if "%main_option%"=="2" call :desktop
if "%main_option%"=="3" call :taskbar
if "%main_option%"=="4" call :explorer_setting
if "%main_option%"=="5" call :install_office
if "%main_option%"=="6" call :activate_windows
if "%main_option%"=="7" call :windows_update
if "%main_option%"=="8" call :uac_setting
if "%main_option%"=="9" call :god_mod
if "%main_option%"=="0" goto byebye
goto main_menu

:: 右键菜单设置子菜单
:submenu_right_click
title 右键菜单设置 & cls
set "submenu_option="
echo *************************************
echo  1. 切换 Windows 10 右键菜单
echo  2. 恢复 Windows 11 右键菜单
echo  3. 添加Hash右键菜单
echo  4. 删除Hash右键菜单
echo  0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" ( 
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul 2>&1
    call :restart_explorer
) else if "%submenu_option%"=="2" ( 
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f  >nul 2>&1
    call :restart_explorer
) else if "%submenu_option%"=="3" ( 
    reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash" /v "MUIVerb" /t REG_SZ /d "Hash" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1" /v "MUIVerb" /t REG_SZ /d "SHA1" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm SHA1 | format-list" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\02SHA256" /v "MUIVerb" /t REG_SZ /d "SHA256" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\02SHA256\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm SHA256 | format-list" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\03SHA384" /v "MUIVerb" /t REG_SZ /d "SHA384" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\03SHA384\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm SHA384 | format-list" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\04SHA512" /v "MUIVerb" /t REG_SZ /d "SHA512" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\04SHA512\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm SHA512 | format-list" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\05MACTripleDES" /v "MUIVerb" /t REG_SZ /d "MACTripleDES" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\05MACTripleDES\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm MACTripleDES | format-list" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\06MD5" /v "MUIVerb" /t REG_SZ /d "MD5" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\06MD5\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm MD5 | format-list" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\07RIPEMD160" /v "MUIVerb" /t REG_SZ /d "RIPEMD160" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\07RIPEMD160\command" /ve /t REG_SZ /d "powershell.exe -noexit get-filehash -literalpath \"%%1\" -algorithm RIPEMD160 | format-list" /f >nul 2>&1
	echo 添加Hash右键菜单完成! & timeout /t 3
)  else if "%submenu_option%"=="4" ( 
	echo 正在删除Hash右键菜单...
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\02SHA256\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\02SHA256" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\03SHA384\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\03SHA384" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\04SHA512\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\04SHA512" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\05MACTripleDES\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\05MACTripleDES" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\06MD5\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\06MD5" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\07RIPEMD160\command" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\07RIPEMD160" /f >nul 2>&1
	reg delete "HKEY_CLASSES_ROOT\*\shell\GetFileHash" /f >nul 2>&1
	echo Hash右键菜单已删除! & timeout /t 3
)  else if "%submenu_option%"=="0" exit /b
goto submenu_right_click

:: 桌面设置
:desktop
title 桌面设置 & cls
set "submenu_option="
echo *************************************
echo  1. 隐藏桌面图标小箭头
echo  2. 显示桌面图标小箭头
echo  3. 隐藏了解此图片（windows聚焦）
echo  4. 显示了解此图片（windows聚焦）
echo  5. 打开桌面图标设置
echo  6. 显示windows版本水印
echo  7. 隐藏windows版本水印
echo  0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" (
    echo 正在隐藏桌面图标小箭头...
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f >nul 2>&1
    attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db" >nul 2>&1
    del "%userprofile%\AppData\Local\iconcache.db" /f /q >nul 2>&1
    call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="2" (
    echo 正在显示桌面图标小箭头...
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f >nul 2>&1
    attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db" >nul 2>&1
    del "%userprofile%\AppData\Local\iconcache.db" /f /q >nul 2>&1
    call :restart_explorer
    echo 操作完成！& timeout /t 2
)  else if "%submenu_option%"=="3" (
    echo 正在隐藏了解此图片...
    REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f >nul 2>&1
    call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="4" (
    echo 正在显示了解此图片...
    REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /f >nul 2>&1
    call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="5" (
    rundll32 shell32.dll,Control_RunDLL desk.cpl,,0
)else if "%submenu_option%"=="6" (
    REG ADD "HKCU\Control Panel\Desktop" /V PaintDesktopVersion /T REG_DWORD /D 1 /F >nul 2>&1
	call :restart_explorer
    echo 操作完成！& timeout /t 2
)else if "%submenu_option%"=="7" (
    REG ADD "HKCU\Control Panel\Desktop" /V PaintDesktopVersion /T REG_DWORD /D 0 /F >nul 2>&1
	call :restart_explorer
    echo 操作完成！& timeout /t 2
)else if "%submenu_option%"=="0" exit /b
goto desktop


:: 任务栏设置
:taskbar
title 任务栏设置 & cls
set "submenu_option="
echo *************************************
echo   1. 一键净化任务栏
echo   2. 禁用小组件
echo   3. 启用小组件
echo   4. 任务视图 — 隐藏
echo   5. 任务视图 — 显示
echo   6. 搜索 - 隐藏
echo   7. 搜索 - 仅显示搜索图标
echo   8. 清除任务栏固定项目（Edge、商店、资源管理器）
echo   9. 自动隐藏任务栏 — 开启
echo  10. 自动隐藏任务栏 — 关闭
echo   0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" (
	call :hide_taskview
	call :hide_search
	call :taskbar_unpin
	call :taskbar_auto_hide_on
	call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="2" (
	call :widgets_disable
	call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="3" (
	call :widgets_enable
	call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="4" (
	call :hide_taskview
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="5" (
	call :show_taskview
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="6" (
	call :hide_search
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="7" (
	call :search_icon
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="8" (
	call :taskbar_unpin
	call :restart_explorer
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="9" (
	call :taskbar_auto_hide_on
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="10" (
	call :taskbar_auto_hide_off
    echo 操作完成！& timeout /t 2
) else if "%submenu_option%"=="0" exit /b
goto taskbar

:widgets_disable
	echo 正在禁用小组件...
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
	sc config Widgets start= disabled >nul
	sc stop Widgets >nul
	sc config WebExperience start= disabled >nul
	sc stop WebExperience >nul
	echo 禁用小组件小组件...OK
exit /b

:widgets_enable
	echo 正在启用小组件...
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1
	sc config Widgets start= demand >nul
	sc config WebExperience start= demand >nul
	sc start WebExperience >nul
	echo 启用小组件...OK
exit /b

:hide_taskview
echo 正在隐藏任务视图...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1
echo 隐藏任务视图...OK
exit /b

:show_taskview
echo 正在显示任务视图...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 1 /f >nul 2>&1
echo 显示任务视图...OK
exit /b

:hide_search
echo 正在隐藏搜索...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >nul 2>&1
echo 正在隐藏搜索...OK
exit /b

:search_icon
echo 正在设置搜索图标...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f >nul 2>&1
echo 设置搜索图标...OK
exit /b

:search_icon
echo 正在设置搜索图标...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f >nul 2>&1
echo 设置搜索图标...OK
exit /b

:taskbar_unpin
echo 正在清除任务栏固定项目...
del /f /q "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1
echo 正在清除任务栏固定项目...OK
exit /b

:taskbar_auto_hide_on
echo 开启任务栏自动隐藏...
powershell -Command "&{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; $v=(Get-ItemProperty -Path $p).Settings; $v[8]=3; Set-ItemProperty -Path $p -Name Settings -Value $v; Stop-Process -Name explorer -Force}"
exit /b

:taskbar_auto_hide_off
echo 开启任务栏自动隐藏...
powershell -Command "&{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; $v=(Get-ItemProperty -Path $p).Settings; $v[8]=2; Set-ItemProperty -Path $p -Name Settings -Value $v; Stop-Process -Name explorer -Force}"
exit /b

:: 资源管理器设置
:explorer_setting
title 资源管理器设置 & cls
set "submenu_option="
echo *************************************
echo  1. 默认打开 此电脑
echo  2. 默认打开 主文件夹
echo  3. 显示 扩展(后缀)名
echo  4. 隐藏 扩展(后缀)名
echo  5. 单击 打开文件
echo  6. 双击 打开文件
echo  7. 显示 复选框
echo  8. 隐藏 复选框
echo  9. Windows 10 此电脑文件夹设置
echo.  
echo  0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f >nul 2>&1
	echo 已设置默认打开此电脑！& timeout /t 5
) else if "%submenu_option%"=="2" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 0 /f >nul 2>&1
	echo 已设置默认打开主文件夹！& timeout /t 5
) else if "%submenu_option%"=="3" (
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
	call :restart_explorer
	echo 已显示扩展名 & timeout /t 6
) else if "%submenu_option%"=="4" (
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 1 /f
	call :restart_explorer
	echo 已隐藏扩展名 & timeout /t 6
) else if "%submenu_option%"=="5" (
	REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V IconUnderline /T REG_DWORD /D 2 /F >nul 2>&1
	REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V ShellState /T REG_BINARY /D 240000001ea8000000000000000000000000000001000000130000000000000062000000 /F >nul 2>&1
	call :restart_explorer
	echo 已设置单击打开文件！& timeout /t 3
) else if "%submenu_option%"=="6" (
	REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V ShellState /T REG_BINARY /D 240000003ea8000000000000000000000000000001000000130000000000000062000000 /F >nul 2>&1
	call :restart_explorer
	echo 已设置双击打开文件！& timeout /t 3
) else if "%submenu_option%"=="7" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d 1 /f >nul 2>&1
	echo 已显示复选框，手动刷新生效 & timeout /t 6
) else if "%submenu_option%"=="8" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d 0 /f >nul 2>&1
	echo 已隐藏复选框，手动刷新生效 & timeout /t 6
) else if "%submenu_option%"=="9" (
	call :this_computer_folder
)  else if "%submenu_option%"=="0" exit /b
goto :explorer_setting

:: 安装 Office
:install_office
cls
title 安装 Office
start powershell -NoProfile -ExecutionPolicy Bypass -Command "irm officetool.plus | iex"
exit /b

:: 激活 Windows & Office
:activate_windows
title 激活 Windows & Office & cls
start powershell -Command "irm https://get.activated.win | iex"
exit /b

@REM From https://www.52pojie.cn/thread-1791338-1-1.html
:: Windows更新设置
:windows_update
title Windows更新设置 & cls
set "submenu_option="
echo *************************************
echo  1. 禁用Windows更新
echo  2. 启用Windows更新
echo  0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
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
	echo 系统已禁止更新 & timeout /t 5
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
	echo 系统已开启更新 & timeout /t 5
) else if "%submenu_option%"=="0" exit /b
goto windows_update

:: Windows 10 此电脑文件夹管理
:this_computer_folder
title Windows 10 此电脑文件夹管理 & cls
set "submenu_option="
echo *************************************
echo   1. 隐藏 3D	 		 2. 恢复 3D
echo   3. 隐藏 视频			 4. 恢复 视频
echo   5. 隐藏 图片			 6. 恢复 图片
echo   7. 隐藏 文档			 8. 恢复 文档
echo   9. 隐藏 下载			10. 恢复 下载
echo  11. 隐藏 音乐			12. 恢复 音乐
echo  13. 隐藏 桌面			14. 恢复 桌面
echo  15. 隐藏所有选项		16. 开启所有选项
echo.  
echo   0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="2" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
) else if "%submenu_option%"=="3" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="4" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
) else if "%submenu_option%"=="5" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="6" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
) else if "%submenu_option%"=="7" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="8" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
) else if "%submenu_option%"=="9" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="10" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
) else if "%submenu_option%"=="11" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="12" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
) else if "%submenu_option%"=="13" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f
	call :restart_explorer
) else if "%submenu_option%"=="14" (
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
	call :restart_explorer
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
	call :restart_explorer
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
	call :restart_explorer
)  else if "%submenu_option%"=="0" exit /b
goto this_computer_folder


:: UAC（用户账户控制）设置 子菜单
:uac_setting
title UAC（用户账户控制）设置 & cls
set "submenu_option="
echo *************************************
echo  1. 从不通知（静默模式，推荐开发调试）
echo  2. 恢复默认（推荐普通用户）
echo  3. 彻底关闭（EnableLUA=0，需重启，UWP不可用）
echo  0. 返回
echo *************************************
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" (
	echo 正在设置为“从不通知”...
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >nul 2>&1
	echo 完成！
	timeout /t 3
) else if "%submenu_option%"=="2" (
	echo 正在恢复默认设置...
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f >nul 2>&1
	echo 完成！
	timeout /t 3
) else if "%submenu_option%"=="3" (
	echo 正在彻底关闭 UAC...
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >nul 2>&1
	echo 设置完成！请重启系统以生效。
	timeout /t 5
)  else if "%submenu_option%"=="0" exit /b
goto uac_setting

:: 上帝模式
:god_mod
explorer shell:::{ED7BA470-8E54-465E-825C-99712043E01C}
exit /b

:restart_explorer
taskkill /f /im explorer.exe >nul 2>&1 & start explorer
exit /b

:byebye
echo byebye
ping -n 2 127.0.0.1 > nul
exit