@echo off
setlocal EnableDelayedExpansion

:: 设置代码页为 UTF-8
chcp 65001 >nul

:: 获取 ver 命令的输出
set VERSION=
for /f "tokens=4-5 delims=[.] " %%i in ('ver') do set VERSION=%%i.%%j
if not defined VERSION (
    set VERSION=未知
    echo 警告: 无法通过 ver 命令获取版本信息
)

:: 初始化变量 
set OS_NAME=未知
set BUILD=未知
set FULL_VERSION=%VERSION%
set PRODUCT_NAME=未知

:: 默认使用 ver 的版本号
set FULL_VERSION=%VERSION%

:: 判断 Windows 版本
if "%VERSION%"=="10.0" (
    :: 对于 Windows 10 和 11，查询注册表
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild ^| find "CurrentBuild" 2^>nul') do set "BUILD=%%a"
    for /f "tokens=3*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName ^| find "ProductName" 2^>nul') do set "PRODUCT_NAME=%%a %%b"
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion ^| find "DisplayVersion" 2^>nul') do set "FULL_VERSION=%%a"
    :: 如果 DisplayVersion 不可用，尝试 ReleaseId
    if "!FULL_VERSION!"=="%VERSION%" (
        for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ReleaseId ^| find "ReleaseId" 2^>nul') do set "FULL_VERSION=%%a"
    )
    :: 通过构建号区分 Windows 10 和 11
    if !BUILD! GEQ 22000 (
        set OS_NAME=Windows 11
    ) else (
        set OS_NAME=Windows 10
    )
) else if "%VERSION%"=="6.3" (
    set OS_NAME=Windows 8.1
) else if "%VERSION%"=="6.2" (
    set OS_NAME=Windows 8
) else if "%VERSION%"=="6.1" (
    set OS_NAME=Windows 7
) else if "%VERSION%"=="6.0" (
    set OS_NAME=Windows Vista
) else if "%VERSION%"=="5.1" (
    set OS_NAME=Windows XP
) else (
    echo 警告: 无法识别操作系统版本
)

:: 输出结果（使用中文标签）
echo 操作系统: %OS_NAME%
echo 产品名称: %PRODUCT_NAME%
echo 版本: %FULL_VERSION%
echo 构建号: %BUILD%

endlocal
pause