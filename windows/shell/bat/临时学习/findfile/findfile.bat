@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

:: 目标文件名（可传参或直接写死） 
set "target=20250606_诺曼底登陆日的转折点.jpg"
set "folder=D:\systemfile\Pictures\BingWallpapers\"

:: 初始化变量 
set "prev="
set "found="
set "next="

for /f "delims=" %%F in ('dir /b /a:-d /o:n "%folder%\*"') do (
    if defined found (
        set "next=%%F"
        goto :show_result
    )

    if /i "%%F"=="%target%" (
        set "found=1"
    ) else (
        set "prev=%%F"
    )
)

:show_result
if defined prev (
    echo 上一个文件: %prev%
) else (
    echo 没有上一个文件（当前是第一个） 
)

if defined found (
    echo 当前文件: %target%
) else (
    echo 没有找到目标文件 
    exit /b
)

if defined next (
    echo 下一个文件: %next%
) else (
    echo 没有下一个文件（当前是最后一个） 
)
