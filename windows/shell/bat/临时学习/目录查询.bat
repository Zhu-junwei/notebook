@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)
chcp 936 > nul
cd /d "%~dp0"
title 系统路径导航工具

for /F "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Desktop ^| find "Desktop"') do set "desktopPath=%%B"
for /F "tokens=3*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Desktop" ^| find "Common Desktop"') do set "commonDesktopPath=%%B"
for /F "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Programs ^| find "Programs"') do set "programsPath=%%B"
for /F "tokens=3*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Programs" ^| find "Common Programs"') do set "commonProgramsPath=%%B"

for /F "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Favorites ^| find "Favorites"') do set "favoritesPath=%%B"
:menu
cls
echo.
echo. 
echo.      
echo ================== 系统文件夹路径 ==================
echo.
echo 1. 用户桌面：%desktopPath%
echo.
echo 2. 公用桌面：%commonDesktopPath%
echo.
echo 3. 用户程序：%programsPath%
echo.
echo 4. 公用程序：%commonProgramsPath%
echo.
echo.5.  收藏夹 ：%favoritesPath%
echo ======================================================
echo.
echo 请选择要打开的路径 (1-5)
echo.


set /p ID="--请选择:"
if "%id%"=="1" goto desktop
if "%id%"=="2" goto commonDesktop
if "%id%"=="3" goto programs
if "%id%"=="4" goto commonPrograms
if "%id%"=="5" goto favorites
:desktop
if exist "%desktopPath%" (
    explorer "%desktopPath%"
    timeout /t 2 >nul
    goto menu
) else (
    echo 错误：用户桌面路径不存在！
    timeout /t 3 >nul
    goto menu
)

:commonDesktop
if exist "%commonDesktopPath%" (
    explorer "%commonDesktopPath%"
    timeout /t 2 >nul
    goto menu
) else (
    echo 错误：公用桌面路径不存在！
    timeout /t 3 >nul
    goto menu
)

:programs
if exist "%programsPath%" (
    explorer "%programsPath%"
    timeout /t 2 >nul
    goto menu
) else (
    echo 错误：用户程序路径不存在！
    timeout /t 3 >nul
    goto menu
)

:commonPrograms
if exist "%commonProgramsPath%" (
    explorer "%commonProgramsPath%"
    timeout /t 2 >nul
    goto menu
) else (
    echo 错误：公用程序路径不存在！
    timeout /t 3 >nul
    goto menu
)

:favorites
if exist "%favoritesPath%" (
    explorer "%favoritesPath%"
    timeout /t 2 >nul
    goto menu
) else (
    echo 错误：公用程序路径不存在！
    timeout /t 3 >nul
    goto menu
)