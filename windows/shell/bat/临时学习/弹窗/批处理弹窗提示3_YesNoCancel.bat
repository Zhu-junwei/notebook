@echo off & chcp 65001>nul
title 弹出窗口选择提示信息 
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $r = [System.Windows.Forms.MessageBox]::Show('直接浏览点是,手动输入点否,退出点取消', '这里是标题', 'YesNoCancel', 'Information'); exit ([int]$r)"
set result=%errorlevel%

echo 返回值: %result%
if %result%==6 (
    echo 你点击了 是
) else if %result%==7 (
    echo 你点击了 否
) else if %result%==2 (
    echo 你点击了 取消
) else (
    echo 未知返回值
)

pause