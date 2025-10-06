@echo off & chcp 65001>nul
:: 你的主要代码放在这里 
echo 正在执行操作... 
echo 这个脚本将在完成后自删除... 

:: 生成临时批处理文件名（带随机数，避免冲突） 
set "temp_cleanup=%temp%\cleanup_%random%.bat"

:: 创建自删除脚本（临时文件） 
(
    echo @echo off
    echo echo 正在删除原脚本... 
    echo del /f /q "%~f0" ^>nul 2^>nul
    echo echo 正在清理临时文件... 
    echo del /f /q "%temp_cleanup%" ^>nul 2^>nul
) > "%temp_cleanup%"

:: 启动自删除脚本并退出当前批处理 
start "" /B cmd /c call "%temp_cleanup%" & exit