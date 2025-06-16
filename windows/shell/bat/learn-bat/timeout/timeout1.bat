@echo off & chcp 65001>nul
:: 需要使用管理员运行，否则会跳转到程序开始位置 
set /p "a=输入等待时间，可以输入任意键打断等待 :"
timeout /t %a%
set /p "a=nobreak不能打断等待，输入等待时间:"
timeout /t %a% /nobreak
set /p "a=输入等待时间，不显示等待的提示:"
timeout /t %a% >nul
pause