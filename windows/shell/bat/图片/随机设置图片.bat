@echo off
setlocal enabledelayedexpansion

:: 设置保存图片的目录
set "downloadDir=%USERPROFILE%\Pictures\BingDailyImages"
if not exist "%downloadDir%" mkdir "%downloadDir%"

:: 生成一个0到7之间的随机数字
set /a "randNum=%random% %% 8"
echo 选择了 %randNum% 天前的图片...

:: 设置图片的日期格式（YYYYMMDD）
set "imageDate="
for /f "delims=" %%j in ('powershell -Command "[datetime]::Today.AddDays(-%randNum%).ToString('yyyyMMdd')"') do set "imageDate=%%j"

:: 设置图片文件名
set "imageFile=%downloadDir%\%imageDate%_BingImage.jpg"
set "finalFile="

:: 检查图片是否已经存在
if exist "%imageFile%" (
    echo 图片已经存在：%imageFile%
    
    :: 目录中随机选择一张已存在的图片
    echo 目录中已存在图片，正在随机选择一张...
    set "fileCount=0"
    
    :: 统计目录中的图片数量
    for %%f in ("%downloadDir%\*_BingImage.jpg") do (
        set /a fileCount+=1
        set "file[!fileCount!]=%%f"
    )
    
    :: 如果有文件，随机选择一张
    if !fileCount! gtr 0 (
        set /a "randFile=%random% %% fileCount + 1"
        for %%i in (!randFile!) do set "finalFile=!file[%%i]!"
        echo 随机选择的图片是：!finalFile!
    ) else (
        echo 目录中没有图片文件可供选择
        goto :end
    )
) else (
    echo 图片不存在，正在下载: %imageDate%_BingImage.jpg
    
    :: 获取图片URL
    set "imageUrl="
    for /f "delims=" %%i in ('powershell -Command "(Invoke-WebRequest 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=%randNum%&n=1').Content | ConvertFrom-Json | Select-Object -ExpandProperty images | Select-Object -ExpandProperty url" 2^>nul') do (
        set "imageUrl=https://www.bing.com%%i"
    )
    
    if defined imageUrl (
        echo 下载URL: !imageUrl!
        curl -o "%imageFile%" "!imageUrl!"
        
        :: 检查是否下载成功
        if exist "%imageFile%" (
            echo 下载成功：%imageFile%
            set "finalFile=%imageFile%"
        ) else (
            echo 下载失败
            goto :end
        )
    ) else (
        echo 无法获取图片URL
        goto :end
    )
)

:: 如果成功获取图片，则设置为桌面背景
if defined finalFile (
    echo 正在设置桌面背景...
    powershell -Command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, '%finalFile%', 3)"
    echo 桌面背景已更新为: %finalFile%
) else (
    echo 未能选择任何图片文件
)

:end
pause