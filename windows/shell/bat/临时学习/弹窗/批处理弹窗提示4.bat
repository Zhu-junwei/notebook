@echo off & chcp 65001>nul
title 弹出窗口选择提示信息 

:: 按钮可选值
:: "OK" "OKCancel" "YesNo" "YesNoCancel" "RetryCancel" "AbortRetryIgnore"
:: 
:: 图标可选值
:: "Information" "Warning" "Error" "Question"
:: 
:: 返回值
:: 1 OK 2 Cancel 3 Abort 4 Retry 5 Ignore 6 Yes 7 No


::powershell -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('操作成功！', '提示', 'OK', 'Information')"
start "" powershell -windowstyle hidden -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('操作成功！', '提示', 'OK', 'Information')"

::set result=%errorlevel%
::
::echo 返回值: %result% 
::if %result%==7	echo 你点击了 否  
::if %result%==6	echo 你点击了 是 
::if %result%==5	echo 你点击了 忽略 
::if %result%==4	echo 你点击了 重试 
::if %result%==3	echo 你点击了 中止 
::if %result%==2	echo 你点击了 取消 
::if %result%==1	echo 你点击了 是 


pause