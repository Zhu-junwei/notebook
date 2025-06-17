@echo off & chcp 65001>nul
:: delims=xxx 定义分隔符 
::  for 默认以空格作分割符，当我们没有写"delims="，就默认以空格分隔。 
:: "delims=" 禁用分割 

echo -------------使用默认的空格分割----------------------
:: for /f "delims=" %%i in ('type "%SystemRoot%\System32\drivers\etc\hosts"') do (
for /f %%a in (%SystemRoot%\System32\drivers\etc\hosts) do (
    echo %%a
)
for /f %%i in ("This is a test") do echo %%i

echo -------------不要分割----------------------
for /f "delims=" %%a in (%SystemRoot%\System32\drivers\etc\hosts) do (
    echo %%a
)
pause