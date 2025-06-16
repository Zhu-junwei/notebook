@echo off & chcp 65001>nul & setlocal enabledelayedexpansion
echo.&echo               蓝奏云文件下载器 &echo.&echo.&echo.
:: 解析蓝奏云文件直链地址，并下载文件 
set "base_url=https://wwqn.lanzoul.com/"
set "file_code=itJvw2t2wb7e"
:: 如果有传参，使用传入的参数，并设置使用到的临时文件 
if not "%~1"=="" set "file_code=%~1"
set "temp_file=%TEMP%\lanzoul.tmp"
:: 获取文件名和请求参数地址 
for /f "tokens=1-10 delims=<> " %%a in ('curl.exe -ks %base_url%%file_code% ^| findstr "title iframe"') do (
	if "%%a"=="iframe" set "iframe_src=%%d" & set "iframe_src=!iframe_src:~5,-1!"
	if "%%a"=="title" set "file_name=%%b")
:: 获取下载地址请求参数 
curl.exe -ks %base_url%!iframe_src! > %temp_file%
for /f "delims=" %%a in ('findstr /C:"wp_sign =" /C:"ajaxdata =" /C:"url :" %temp_file%') do ( set "line=%%a"
	echo !line! | findstr /C:"wp_sign =" >nul && for /f "tokens=2 delims='" %%b in ("!line!") do set "wp_sign=%%b"
	echo !line! | findstr /C:"ajaxdata =" >nul && for /f "tokens=2 delims='" %%b in ("!line!") do set "ajaxdata=%%b"
	echo !line! | findstr /C:"url :" >nul && for /f "tokens=2 delims='" %%b in ("!line!") do set "url=%%b")
:: 获取下载地址josn格式 
curl.exe -ks -o %temp_file% "%base_url%%url%" -H "Content-Type: application/x-www-form-urlencoded" -H "Referer: %base_url%!iframe_src!" ^
 --data "action=downprocess&websignkey=%ajaxdata%&signs=%ajaxdata%&sign=%wp_sign%&websign=&kd=1&ves=1"
:: 解析拼接下载地址 
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "$json = Get-Content '!temp_file!' ^| ConvertFrom-Json; Write-Output ($json.dom + '/file/' + $json.url)"`) do set "final_url=%%i"
:: 下载文件，需要设置请求头Accept-Language 
echo 正在下载!file_name!&echo.
curl.exe -kL -H "Accept-Language: zh-CN,zh;q=0.9" -o !file_name! %final_url%
del %temp_file% &echo.&echo 下载完成。&pause>nul