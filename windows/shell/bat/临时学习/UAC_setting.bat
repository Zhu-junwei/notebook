@echo off
::获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit cd /d "%~dp0"

title 设置用户账户控制（UAC）级别
color 1F

:menu
cls
set choice=null
echo ================================
echo      设置 UAC（用户账户控制）
echo ================================
echo.
echo  1. 从不通知（静默模式，推荐开发调试）
echo  2. 恢复默认（推荐普通用户）
echo  3. 彻底关闭（EnableLUA=0，需重启，UWP不可用）
echo  0. 退出
echo.
set /p choice=请选择操作（输入数字）： 

if "%choice%"=="1" goto silent_mode
if "%choice%"=="2" goto default_mode
if "%choice%"=="3" goto disable_uac
if "%choice%"=="0" exit
goto menu

:silent_mode
echo 正在设置为“从不通知”...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f
echo 完成！
:: 等待3S回到菜单
timeout /t 3
goto menu

:default_mode
echo 正在恢复默认设置...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
echo 完成！
:: 等待3S回到菜单
timeout /t 3
goto menu

:disable_uac
echo 正在彻底关闭 UAC...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
echo 设置完成！请重启系统以生效。
:: 等待3S回到菜单
timeout /t 3
goto menu
