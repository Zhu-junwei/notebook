@echo off
echo 恢复 Windows 任务栏窗口预览...

:: 删除 ExtendedUIHoverTime 键（恢复默认值）
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ExtendedUIHoverTime /f

:: 重启资源管理器以生效
taskkill /f /im explorer.exe
start explorer.exe

echo 操作完成！任务栏窗口预览已恢复。
pause
