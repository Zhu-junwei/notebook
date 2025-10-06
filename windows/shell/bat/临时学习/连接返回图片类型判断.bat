@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

set "url=https://api.paugram.com/wallpaper/"
set "is_image=0"

for /f "delims=" %%A in ('curl.exe -sI -L "%url%" ^| findstr /i "Content-Type:"') do (
    echo 响应头: %%A
    echo %%A | findstr /i "image/jpeg image/jpg image/png image/bmp" >nul && set "is_image=1"
)

if !is_image! equ 1 (
    echo 返回结果是图片（jpg/jpeg/png/bmp）。
) else (
    echo 返回结果不是目标图片类型。
)

pause