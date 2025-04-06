@echo off
set LNK_NAME=网络连接

:: 删除当前用户的桌面快捷方式
del /f /q "%USERPROFILE%\Desktop\%LNK_NAME%.lnk" 2>nul

:: 删除公共用户的桌面快捷方式（针对系统级安装的快捷方式）
del /f /q "%PUBLIC%\Desktop\%LNK_NAME%.lnk" 2>nul

if exist "%USERPROFILE%\Desktop\%LNK_NAME%.lnk" (
    echo 删除失败，请检查快捷方式路径！ & pause
) else (
    echo 快捷方式已成功删除！ & pause
)