@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

:: 目标文件名（可传参或直接写死） 
set "target=20250614_静谧之声.jpg"
set "folder=D:\systemfile\Pictures\BingWallpapers\"

:: 上一个文件的变量 
set "found="

for /f "delims=" %%F in ('dir /b /a:-d /o:n "%folder%\*"') do (
    if defined found (
        echo 下一个文件: %%F
        goto :eof
    )
    if /i "%%F"=="%target%" (
        set "found=1"
    )
)

if not defined found (
    echo 没有找到目标文件 
) else (
    echo 没有下一个文件（当前是最后一个）
)
