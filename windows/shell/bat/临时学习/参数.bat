@echo off & chcp 65001>nul & setlocal EnableDelayedExpansion
for %%a in (%*) do (
	set /a index+=1
    set "param[!index!]=%%a"
    set "all_param=!all_param! "%%a""
)

:: 去掉开头的空格并打印 
if defined all_param (
	set "all_param=!all_param:~1!"
	echo 所有参数: !all_param!
) else (
	echo 没有参数 
)

pause