@echo off & chcp 65001>nul & setlocal EnableDelayedExpansion
net session >nul 2>&1 || (echo 请以管理员身份运行 & pause>nul)

:: 初始化一些必要参数 
set "appName=SimpleWallpaper"
set "appNameCN=简单壁纸"
set "installDir=%LOCALAPPDATA%\%appName%"
set "configFile=%installDir%\smw_config.ini"
set "requiredParams=smw_wallpaperPath"
set "app_regedit=HKCR\DesktopBackground\shell\wallpaper"

:: 手动运行/右键运行  
set "cmd=%~1"
if not defined cmd (goto :human_menu) else (goto :cmd_menu)

:human_menu
mode con cols=60 lines=25 & color 0A
title 右键简单壁纸 v1.2
set "c="
echo.&echo.&echo.
echo				右键简单壁纸	&echo.&echo.&echo.
echo			1. 安装	2. 卸载	0.退出&echo. 
set /p c=请输入你的选择: 
if "%c%"=="1"  call :install
if "%c%"=="2"  call :uninstall
if "%c%"=="0" exit
goto human_menu 

:cmd_menu
call :print_log "---------start---------"
call :print_log "执行命令：%cmd%"
call :init_app
if /i "%cmd%"=="prev" call :choose_wallpaper
if /i "%cmd%"=="next" call :choose_wallpaper
if /i "%cmd%"=="rand" call :choose_wallpaper
if /i "%cmd%"=="latest" call :choose_wallpaper
if /i "%cmd%"=="uninstall" call :uninstall
if /i "%cmd%"=="auto" call :auto
if /i "%cmd%"=="set_wallpaperPath" call :set_wallpaperPath
if /i "%cmd%"=="open_wallpaperPath" call :open_wallpaperPath
if /i "%cmd%"=="load_bing_wallpaper" call :load_bing_wallpaper
call :print_log "---------end---------"
exit

:init_app
call :print_log "加载配置文件..."
:: 读取配置文件 
for /f "usebackq eol=# tokens=1,* delims==" %%a in (%configFile%) do set "%%a=%%b"
:: 检查配置文件参数  
for %%p in (%requiredParams%) do (
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
	set "smw_wallpaperPath=%%P\%appName%"
)
call :save_config

copy /y "%~f0" "%installDir%\%appName%.bat" >nul
set "vbsPath=%installDir%\%appName%.vbs"
(
	echo Set shell = CreateObject("Shell.Application"^)
	echo Set fso = CreateObject("Scripting.FileSystemObject"^)
	echo scriptDir = fso.GetParentFolderName(WScript.ScriptFullName^)
	echo args = ""
	echo For i = 0 To WScript.Arguments.Count - 1
	echo     args = args ^& " " ^& Chr(34^) ^& WScript.Arguments(i^) ^& Chr(34^)
	echo Next
	echo shell.ShellExecute "cmd.exe", "/c cd /d """ ^& scriptDir ^& """ && %appName%.bat" ^& args, "", "runas", 0
) > "%vbsPath%"

call :print_log "安装简单壁纸 start"
reg add "%app_regedit%" /v "MUIVerb" /t REG_SZ /d "简单壁纸" /f >nul 2>&1
reg add "%app_regedit%" /v "Icon" /t REG_SZ /d "imageres.dll,-113" /f >nul 2>&1
reg add "%app_regedit%" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
reg add "%app_regedit%\shell\1_pre" /v "MUIVerb" /t REG_SZ /d "上一张" /f >nul 2>&1
reg add "%app_regedit%\shell\1_pre" /v "Icon" /t REG_SZ /d "shell32.dll,-16749" /f >nul 2>&1
reg add "%app_regedit%\shell\1_pre\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" prev" /f >nul 2>&1
reg add "%app_regedit%\shell\2_next" /v "MUIVerb" /t REG_SZ /d "下一张" /f >nul 2>&1
reg add "%app_regedit%\shell\2_next" /v "Icon" /t REG_SZ /d "shell32.dll,-16750" /f >nul 2>&1
reg add "%app_regedit%\shell\2_next\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" next" /f >nul 2>&1
reg add "%app_regedit%\shell\3_random" /v "MUIVerb" /t REG_SZ /d "随机" /f >nul 2>&1
reg add "%app_regedit%\shell\3_random" /v "Icon" /t REG_SZ /d "imageres.dll,-1401" /f >nul 2>&1
reg add "%app_regedit%\shell\3_random\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" rand" /f >nul 2>&1
reg add "%app_regedit%\shell\4_latest" /v "MUIVerb" /t REG_SZ /d "最新" /f >nul 2>&1
reg add "%app_regedit%\shell\4_latest" /v "Icon" /t REG_SZ /d "imageres.dll,-5100" /f >nul 2>&1
reg add "%app_regedit%\shell\4_latest\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" latest" /f >nul 2>&1
reg add "%app_regedit%\shell\5_0setting" /v CommandFlags /t REG_DWORD /d 0x00000008 /f >nul 2>&1
reg add "%app_regedit%\shell\5_network" /v "MUIVerb" /t REG_SZ /d "联网壁纸" /f >nul 2>&1
reg add "%app_regedit%\shell\5_network" /v "Icon" /t REG_SZ /d "imageres.dll,-1404" /f >nul 2>&1 
reg add "%app_regedit%\shell\5_network" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
reg add "%app_regedit%\shell\5_network\shell\1_bingWallpaper" /v "MUIVerb" /t REG_SZ /d "下载必应壁纸" /f >nul 2>&1
reg add "%app_regedit%\shell\5_network\shell\1_bingWallpaper" /v "Icon" /t REG_SZ /d "imageres.dll,-184" /f >nul 2>&1
reg add "%app_regedit%\shell\5_network\shell\1_bingWallpaper\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" load_bing_wallpaper" /f >nul 2>&1
reg add "%app_regedit%\shell\6_0setting" /v CommandFlags /t REG_DWORD /d 0x00000008 /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting" /v "MUIVerb" /t REG_SZ /d "设置" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting" /v "Icon" /t REG_SZ /d "shell32.dll,-16826" /f >nul 2>&1 
reg add "%app_regedit%\shell\6_setting" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\1_wallpaperPath" /v "MUIVerb" /t REG_SZ /d "设置壁纸目录" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\1_wallpaperPath" /v "Icon" /t REG_SZ /d "shell32.dll,-46" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\1_wallpaperPath\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" set_wallpaperPath" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\2_openWallpaperPath" /v "MUIVerb" /t REG_SZ /d "打开壁纸目录" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\2_openWallpaperPath" /v "Icon" /t REG_SZ /d "shell32.dll,-37" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\2_openWallpaperPath\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" open_wallpaperPath" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\3_openInstallDir" /v "MUIVerb" /t REG_SZ /d "打开应用目录" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\3_openInstallDir" /v "Icon" /t REG_SZ /d "shell32.dll,-264" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\3_openInstallDir\command" /ve /t REG_SZ /d "explorer \"%installDir%\"" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\4_cleanlog" /v "MUIVerb" /t REG_SZ /d "清理日志" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\4_cleanlog" /v "Icon" /t REG_SZ /d "shell32.dll,-261" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\4_cleanlog\command" /ve /t REG_SZ /d "cmd.exe /c del /F /Q \"%installDir%\\log\\smw.log\"" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\5_uninstall" /v "MUIVerb" /t REG_SZ /d "卸载" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\5_uninstall" /v "Icon" /t REG_SZ /d "shell32.dll,-32" /f >nul 2>&1
reg add "%app_regedit%\shell\6_setting\shell\5_uninstall\command" /ve /t REG_SZ /d "wscript.exe \"\"%vbsPath%\"\" uninstall" /f >nul 2>&1
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
for %%A in ("%current_wallpaper%") do set "current_name=%%~nxA"
set "prev=" & set "found=" & set "next=" & set /a count=0 & set "rand="
for /f "delims=" %%F in ('dir /b /a:-d /o:-d "%smw_wallpaperPath%\*.bmp" "%smw_wallpaperPath%\*.jpg" "%smw_wallpaperPath%\*.jpeg" "%smw_wallpaperPath%\*.png" 2^>nul') do (
	set /a count+=1
	set /a r=%random% %% !count!
	if !r! EQU 0 set "rand=%smw_wallpaperPath%\%%~F"
	if not defined latest set "latest=%smw_wallpaperPath%\%%~F"
	set "last_file=%smw_wallpaperPath%\%%~F"
    if not defined found (
        if "%%F"=="%current_name%" (
            set "found=1"
        ) else set "prev=%smw_wallpaperPath%\%%~F"
    ) else (
        if not defined next set "next=%smw_wallpaperPath%\%%~F"
    )
)
if not defined found if defined latest set "prev=%latest%"
if not defined next if defined latest set "next=%latest%"
if not defined prev set "prev=%last_file%"
if "%direction%"=="prev" set "selected_wallpaper=%prev%"
if "%direction%"=="next" set "selected_wallpaper=%next%"
if "%direction%"=="rand" set "selected_wallpaper=%rand%"
if "%direction%"=="latest" set "selected_wallpaper=%latest%"
if not defined selected_wallpaper exit /b
call :set_wallpaper
exit /b

:set_wallpaper
call :print_log "设置壁纸： %selected_wallpaper%"
powershell -Command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [void][Wallpaper]::SystemParametersInfo(20, 0, '%selected_wallpaper%', 3)"
exit /b

:set_wallpaperPath
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

:open_wallpaperPath
explorer "%smw_wallpaperPath%"
exit /b

:: 下载bing壁纸 
:load_bing_wallpaper
if not exist "%smw_wallpaperPath%" mkdir "%smw_wallpaperPath%"
set "baseUrl=https://www.bing.com"
set /a bCounter=0
for /L %%i in (0,1,1) do (
	set /a index = %%i * 7
	set /a num = %%i + 7
	set "jsonUrl=!baseUrl!/HPImageArchive.aspx?format=js&idx=!index!&n=!num!&mkt=zh-CN&nc=1614319565639&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
	for /f "usebackq tokens=1,* delims=@" %%A in (`
		powershell -nologo -command ^
		"$ProgressPreference = 'SilentlyContinue';"^
		"$json = Invoke-RestMethod -Uri '!jsonUrl!' -UseBasicParsing;" ^
		"$json.images | ForEach-Object { Write-Output ('!baseUrl!' + $_.url + '@' + $_.enddate + '_' + $_.title); }" ^
	`) do (
		set /a bCounter+=1
		set "imageUrl[!bCounter!]=%%A"
		set "imageName[!bCounter!]=%%B"
	)
)
call :print_log "获取Bing壁纸数量: %bCounter%"
if %bCounter% EQU 0 call :show_message "无可用联网壁纸" & exit /b
set /a downloadCounter=0
for /L %%i in (!bCounter!,-1,1) do (
	set "bingImagePath=%smw_wallpaperPath%\!imageName[%%i]!.jpg"
	if not exist !bingImagePath! (
		call :print_log 下载地址：!imageUrl[%%i]!
		call :print_log 下载文件：!imageName[%%i]!.jpg
		call :print_log 本地地址: %smw_wallpaperPath%\!imageName[%%i]!.jpg
		curl.exe --retry 2 --max-time 15 -so "!bingImagePath!" "!imageUrl[%%i]!"
		set "selected_wallpaper=!bingImagePath!"
		set /a downloadCounter+=1
	)
)
if %downloadCounter% GTR 0 (
	call :show_message "已成功下载 %downloadCounter% 张必应壁纸"
) else (
	call :show_message "本地已更新，无需重复下载"
)
if defined selected_wallpaper call :set_wallpaper
exit /b

:save_config
(for %%p in (%requiredParams%) do echo %%p=!%%p!) > "%configFile%"
exit /b

:show_message
start "" powershell -windowstyle hidden -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('%~1', '%appNameCN%', 'OK', 'Information')"
exit /b

:print_log
echo [%date% %time%] %~1 >> %installDir%\log\smw.log
exit /b

pause