@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

:loade_bing_wallpaper
for /f "usebackq delims=" %%P in (`powershell -nologo -noprofile -command "[Environment]::GetFolderPath('MyPictures')"`) do (
    set "downloadDir=%%P\test"
)
if not exist "!downloadDir!" mkdir "!downloadDir!"
echo 正在获取图片信息... 
set "baseUrl=https://www.bing.com"

set /a counter=0

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
		echo %%A
		echo %%B
		set /a counter+=1
		set "imageUrl[!counter!]=%%A"
		set "imageName[!counter!]=%%B"
	)
)

echo 总计:%counter%

for /L %%i in (!counter!,-1,1) do (
	echo 下载地址：!imageUrl[%%i]!
	echo 下载文件：!imageName[%%i]!.jpg
	echo 本地地址: %downloadDir%\!imageName[%%i]!.jpg
	curl.exe --retry 2 --max-time 15 -so "%downloadDir%\!imageName[%%i]!.jpg" "!imageUrl[%%i]!"
)

echo 所有图片下载完成，保存在 %downloadDir% 目录 
pause