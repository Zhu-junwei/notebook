@echo off & chcp 65001>nul & setlocal enabledelayedexpansion

echo.&echo     设置Bing每日桌面背景 &echo.  
for /f "usebackq delims=" %%P in (`powershell -nologo -noprofile -command "[Environment]::GetFolderPath('MyPictures')"`) do (
    set "downloadDir=%%P\BingWallpapers"
)
if not exist "!downloadDir!" mkdir "!downloadDir!"
echo 正在获取图片信息... 
set "baseUrl=https://www.bing.com"
set "jsonUrl=!baseUrl!/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN&nc=1614319565639&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
for /f "usebackq tokens=1,* delims==" %%A in (`
	powershell -nologo -command ^
    "$json = Invoke-RestMethod -Uri '!jsonUrl!' -UseBasicParsing;" ^
    "$img = $json.images[0];" ^
    "Write-Output ('imageUrl=!baseUrl!' + $img.url);" ^
    "Write-Output ('imageName=' + $img.enddate + '_'+ $img.title);" ^
`) do (
    set "%%A=%%B"
)
set "imageFile=!downloadDir!\!imageName!.jpg"
if not exist !imageFile! (
    if "!imageUrl:~20,1!" NEQ "" (
		echo 正在下载图片：!imageName!.jpg
		curl.exe --retry 2 --max-time 30 -so "!imageFile!" "!imageUrl!"
	)
) else echo 图片!imageName!.jpg已存在，跳过下载 
if exist "!imageFile!" (
    echo 正在设置桌面背景...
    powershell -Command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [void][Wallpaper]::SystemParametersInfo(20, 0, '!imageFile!', 3)"
	echo 桌面背景已更新为: !imageFile!
) else (
    echo 未能下载或找到图片文件 
)

timeout /t 10