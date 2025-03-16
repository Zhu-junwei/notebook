@echo off
echo 关闭 Windows 任务栏窗口预览...

:: 修改注册表，禁用任务栏预览
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ExtendedUIHoverTime /t REG_DWORD /d 60000 /f

:: 重启资源管理器以生效
taskkill /f /im explorer.exe
start explorer.exe

echo 操作完成！任务栏窗口预览已关闭。
pause
