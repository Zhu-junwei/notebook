@echo off
setlocal enabledelayedexpansion

:: 设置保存图片的目录
set "downloadDir=%USERPROFILE%\Pictures\BingDailyImages"
if not exist "%downloadDir%" mkdir "%downloadDir%"

:: 设置要下载的天数（0=今天，1=昨天，依此类推）
set "daysToDownload=7"

echo 正在下载最近 %daysToDownload% 天的 Bing 每日图片...
echo.

for /l %%d in (0,1,%daysToDownload%) do (
    echo 正在获取 %%d 天前的图片...
    
    :: 获取图片URL
    for /f "delims=" %%i in ('powershell -Command "(Invoke-WebRequest 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=%%d&n=1').Content | ConvertFrom-Json | Select-Object -ExpandProperty images | Select-Object -ExpandProperty url" 2^>nul') do (
        set "imageUrl=https://www.bing.com%%i"
        set "imageDate="
        
        :: 获取图片日期（格式：YYYYMMDD）
        for /f "delims=" %%j in ('powershell -Command "[datetime]::Today.AddDays(-%%d).ToString('yyyyMMdd')"') do set "imageDate=%%j"
        
        :: 下载图片
        echo 正在下载: !imageDate!_BingImage.jpg
        curl -o "%downloadDir%\!imageDate!_BingImage.jpg" "!imageUrl!"
        
        :: 检查是否下载成功
        if exist "%downloadDir%\!imageDate!_BingImage.jpg" (
            echo 下载成功
        ) else (
            echo 下载失败
        )
        echo.
    )
)

echo 所有图片下载完成，保存在 %downloadDir% 目录
pause