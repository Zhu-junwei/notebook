@echo off & chcp 65001>nul
:: "delims=" 禁用分割
:: for /f "delims=" %%i in ('type "%SystemRoot%\System32\drivers\etc\hosts"') do (
for /f "delims=" %%i in (%SystemRoot%\System32\drivers\etc\hosts) do (
    echo %%i
)
echo -----------------------------------
for /f %%i in ('dir /b') do echo %%i

echo -----------------------------------
:: 默认空格制表符分割，结果是This
for /f %%i in ("This is a test") do echo %%i
:: tokens指定读取第几列数据，*表示余下所有
for /f "tokens=1,2,3,*" %%a in ("This is a test haha") do (
	echo %%a
	echo %%b
	echo %%c
	echo %%d
)
echo -----------------------------------
:: 指定分隔符和要取的值 
for /f "tokens=1,2,3 delims=," %%a in ("z,18,男") do echo Name: %%a Age: %%b Gender: %%c
echo -------------1----------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do echo IPv4:%%a
echo -------------2----------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set "ip=%%a" & call echo IPv4:%%ip:~1%%
echo -------------3----------------------
for /f "usebackq tokens=2 delims=:" %%a in (`ipconfig ^| findstr "IPv4"`) do echo IPv4:%%a
pause