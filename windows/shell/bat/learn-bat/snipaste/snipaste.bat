@echo off & chcp 65001 >nul
:: 1. 检查 Snipaste.exe 是否正在运行 
tasklist /FI "IMAGENAME eq Snipaste.exe" 2>NUL | find /I "Snipaste.exe" >NUL
set was_running=%ERRORLEVEL%

:: 2. 如果未运行，则启动 Snipaste.exe
if %was_running% neq 0 (
    echo Snipaste.exe 未运行，正在启动... 
    start "" "Snipaste.exe"
    timeout /t 2 >nul
)

:: 3. 执行截图并保存，这里使用了snipaste的自动保存功能 
:: 如果需要使用自定义的保存，可以参考snipaste文档 
:: https://docs.snipaste.com/zh-cn/command-line-options 
echo 正在执行全屏截图并保存... 
Snipaste.exe snip --full -o success
timeout /t 1 >nul

:: 4. 如果最初未运行，则退出 Snipaste.exe（还原状态） 
if %was_running% neq 0 (
    echo 还原状态，退出 Snipaste.exe...
    start "" "Snipaste.exe" exit
    timeout /t 1 >nul
)

echo 操作完成！ 
timeout /t 2 >nul