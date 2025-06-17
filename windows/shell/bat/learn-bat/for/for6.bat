@echo off & chcp 65001>nul

:: tokens 显示指定的列 
:: tokens=x,y,m-n,*指定读取第几列数据，*表示余下所有 
echo -------------tokens指定读取第几列数据----------------------
for /f "tokens=1,2,3,*" %%a in ("This is a test haha") do (
	echo %%a
	echo %%b
	echo %%c
	echo %%d
)
echo ------------- 指定分隔符和要取的值 ----------------------
for /f "tokens=1-4 delims=，" %%a in ("床前明月光，疑是地上霜，举头望明月，低头思故乡") do (
	echo %%a
	echo %%b
	echo %%c
	echo %%d
)
for /f "tokens=1,2,3 delims=," %%a in ("z,18,男") do echo Name: %%a Age: %%b Gender: %%c
echo -------------1----------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do echo IPv4:%%a
echo -------------2----------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set "ip=%%a" & call echo IPv4:%%ip:~1%%
echo -------------3----------------------
:: usebackq 改变字符串或命令的引号解析方式，使你可以： 
::			使用 反引号（`） 来执行命令； 
::			使用 双引号（"） 来处理包含空格的文件名。 
::			使用 单引号（'） 来处理字符串
for /f "usebackq tokens=2 delims=:" %%a in (`ipconfig ^| findstr "IPv4"`) do echo IPv4:%%a
for /f "usebackq" %%i in ("C:\Program Files\Windows Security\BrowserCore\manifest.json") do echo %%i
for /f "usebackq delims=" %%a in ('Hello "AnsiPeter" World') do echo.%%a
pause