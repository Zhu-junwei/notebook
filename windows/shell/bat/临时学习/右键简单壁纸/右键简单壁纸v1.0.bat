@echo off & chcp 65001>nul & setlocal EnableDelayedExpansion
net session >nul 2>&1 || (echo 请以管理员身份运行 & pause>nul)

:: 初始化一些必要参数 
set "app_name=SimpleWallpaper"
set "installDir=%LOCALAPPDATA%\%app_name%"
set "config_file=%installDir%\smw_config.ini"
set "required_params=smw_wallpaperPath"
set "app_regedit=HKCR\DesktopBackground\shell\wallpaper"

:: 手动运行/右键运行  
set "cmd=%~1"
if not defined cmd (goto :human_menu) else (goto :cmd_menu)

:human_menu
mode con cols=60 lines=25 & color 0A
title 右键简单壁纸 离线版 v1.0
set "c="
echo.&echo.&echo.
echo				右键简单壁纸	&echo.&echo.&echo.
echo				1. 安装	2. 卸载 &echo. 
set /p c=请输入你的选择: 
if "%c%"=="1"  call :install
if "%c%"=="2"  call :uninstall
if "%c%"=="0" exit
goto manual_menu 

:cmd_menu
call :print_log "---------start---------"
call :print_log "执行命令：%cmd%"
call :init_app
if /i "%cmd%"=="next" call :choose_wallpaper
if /i "%cmd%"=="pre" call :choose_wallpaper
if /i "%cmd%"=="random" call :choose_wallpaper
if /i "%cmd%"=="uninstall" call :uninstall
if /i "%cmd%"=="auto" call :auto
if /i "%cmd%"=="wallpaperPath" call :wallpaperPath
call :print_log "---------end---------"
exit

:init_app
call :print_log "加载配置文件..."
:: 读取配置文件 
for /f "usebackq eol=# tokens=1,* delims==" %%a in (%config_file%) do set "%%a=%%b"
:: 检查配置文件参数  
for %%p in (%required_params%) do (
	if not defined %%p (call :print_log 没有参数%%p & exit) else (set "tv=!%%p!" & call :print_log "%%p=!tv!")
)
for /f "tokens=1,2,*" %%a in ('reg query "HKCU\Control Panel\Desktop" /v Wallpaper ^| findstr /i "Wallpaper"') do (
	set "current_wallpaper=%%~c"
	call :print_log "当前壁纸路径: !current_wallpaper!"
)
exit /b

:install
if not exist "%installDir%" mkdir "%installDir%"
if not exist "%installDir%\log" mkdir "%installDir%\log"
:: 设置壁纸下载位置 
for /f "usebackq delims=" %%P in (`powershell -nologo -noprofile -command "[Environment]::GetFolderPath('MyPictures')"`) do (
	set "smw_wallpaperPath=%%P\%app_name%"
)
call :save_config

copy /y "%~f0" "%installDir%\%app_name%.bat" >nul
set "vbsPath=%installDir%\%app_name%.vbs"
(
	echo Set shell = CreateObject("Shell.Application"^)
	echo Set fso = CreateObject("Scripting.FileSystemObject"^)
	echo scriptDir = fso.GetParentFolderName(WScript.ScriptFullName^)
	echo args = ""
	echo For i = 0 To WScript.Arguments.Count - 1
	echo     args = args ^& " " ^& Chr(34^) ^& WScript.Arguments(i^) ^& Chr(34^)
	echo Next
	echo shell.ShellExecute "cmd.exe", "/c cd /d """ ^& scriptDir ^& """ && %app_name%.bat" ^& args, "", "runas", 0
) > "%vbsPath%"

call :print_log "安装简单壁纸 start"
reg add "%app_regedit%" /v "MUIVerb" /t REG_SZ /d "简单壁纸" /f >nul 2>&1
reg add "%app_regedit%" /v "Icon" /t REG_SZ /d "shell32.dll,-236" /f >nul 2>&1
reg add "%app_regedit%" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
reg add "%app_regedit%\shell\1_pre" /v "MUIVerb" /t REG_SZ /d "上一张" /f >nul 2>&1
reg add "%app_regedit%\shell\1_pre" /v "Icon" /t REG_SZ /d "shell32.dll,-16749" /f >nul 2>&1
reg add "%app_regedit%\shell\1_pre\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" pre" /f >nul 2>&1
reg add "%app_regedit%\shell\2_next" /v "MUIVerb" /t REG_SZ /d "下一张" /f >nul 2>&1
reg add "%app_regedit%\shell\2_next" /v "Icon" /t REG_SZ /d "shell32.dll,-16750" /f >nul 2>&1
reg add "%app_regedit%\shell\2_next\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" next" /f >nul 2>&1
reg add "%app_regedit%\shell\3_random" /v "MUIVerb" /t REG_SZ /d "随机" /f >nul 2>&1
reg add "%app_regedit%\shell\3_random" /v "Icon" /t REG_SZ /d "imageres.dll,-1401" /f >nul 2>&1
reg add "%app_regedit%\shell\3_random\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" random" /f >nul 2>&1
reg add "%app_regedit%\shell\4_0setting" /v CommandFlags /t REG_DWORD /d 0x00000008 /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting" /v "MUIVerb" /t REG_SZ /d "设置" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting" /v "Icon" /t REG_SZ /d "shell32.dll,-16826" /f >nul 2>&1 
reg add "%app_regedit%\shell\4_setting" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\1_wallpaperPath" /v "MUIVerb" /t REG_SZ /d "设置壁纸目录" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\1_wallpaperPath" /v "Icon" /t REG_SZ /d "shell32.dll,-46" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\1_wallpaperPath\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" wallpaperPath" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\2_openInstallDir" /v "MUIVerb" /t REG_SZ /d "打开应用目录" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\2_openInstallDir" /v "Icon" /t REG_SZ /d "shell32.dll,-264" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\2_openInstallDir\command" /ve /t REG_SZ /d "explorer \"%installDir%\"" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\4_cleanlog" /v "MUIVerb" /t REG_SZ /d "清理日志" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\4_cleanlog" /v "Icon" /t REG_SZ /d "shell32.dll,-261" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\4_cleanlog\command" /ve /t REG_SZ /d "cmd.exe /c del /F /Q \"%installDir%\\log\\smw.log\"" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\5_uninstall" /v "MUIVerb" /t REG_SZ /d "卸载" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\5_uninstall" /v "Icon" /t REG_SZ /d "shell32.dll,-32" /f >nul 2>&1
reg add "%app_regedit%\shell\4_setting\shell\5_uninstall\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" uninstall" /f >nul 2>&1
call :print_log "安装简单壁纸 end"
echo 安装成功，请设置壁纸目录后使用！ 
timeout /t 6
exit /b

:uninstall
set "uninstall_script=%TEMP%\uninstall_script.bat"
(
	echo @echo off
	echo reg delete "%app_regedit%" /f ^>nul 2^>nul
	echo rd /s /q "%installDir%" ^>nul 2^>nul
	echo del /F /Q "%%~f0" ^>nul 2^>nul
) > "%uninstall_script%"
start "" /B cmd /c call "%uninstall_script%" & exit

:choose_wallpaper
set "direction=%cmd%"
set "wallpaper_count=0"
if not exist "%smw_wallpaperPath%" call :print_log "壁纸目录：%smw_wallpaperPath% 不存在！" & exit
for %%E in (bmp jpg jpeg png) do (
	for /f "delims=" %%F in ('dir /b /a:-d /o:-d "%smw_wallpaperPath%\*.%%E" 2^>nul') do (
		set /a wallpaper_count+=1
		set "wallpaper[!wallpaper_count!]=%smw_wallpaperPath%\%%F"
	)
)
call :print_log "加载壁纸数量：%wallpaper_count%"
if %wallpaper_count% EQU 0 ( exit /b 1 )
set current_index=0
for /L %%i in (1,1,!wallpaper_count!) do (
	if /i "!wallpaper[%%i]!"=="%current_wallpaper%" (
		set current_index=%%i
	)
)
if %wallpaper_count% EQU 1 set /a current_index=0
goto :found_wallpaper
exit /b

:found_wallpaper
set /a new_index=current_index
if /i "%direction%"=="pre" (
	set /a new_index-=1
	if !new_index! LSS 1 set /a new_index=%wallpaper_count%
) else if /i "%direction%"=="next" (
	set /a new_index+=1
	if !new_index! GTR %wallpaper_count% set /a new_index=1
) else if /i "%direction%"=="random" (
	:rand_retry
	set /a new_index=!random! %% %wallpaper_count% + 1
	if !new_index! EQU !current_index! goto :rand_retry
)

for %%i in (%new_index%) do set "selected_wallpaper=!wallpaper[%%i]!"
call :set_wallpaper
exit /b

:set_wallpaper
call :print_log "设置壁纸： %selected_wallpaper%"
powershell -Command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [void][Wallpaper]::SystemParametersInfo(20, 0, '%selected_wallpaper%', 3)"
exit /b

:wallpaperPath
for /f "usebackq delims=" %%i in (
	`powershell -noprofile -command "$shell=New-Object -ComObject Shell.Application; $folder=$shell.BrowseForFolder(0,'请选择壁纸文件夹',0,0); if($folder){$folder.Self.Path}"`
) do set "selectedFolder=%%i"
if not defined selectedFolder (
	call :print_log "未输入路径，操作已取消。"
	exit /b
)
set "smw_wallpaperPath=%selectedFolder%"
call :print_log "改变图片目录：%selectedFolder%"
call :save_config
exit /b

:save_config
(for %%p in (%required_params%) do echo %%p=!%%p!) > "%config_file%"
exit /b

:print_log
echo [%date% %time%] %~1 >> %installDir%\log\smw.log
exit /b

pause