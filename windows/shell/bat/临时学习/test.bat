@echo off & chcp 65001>nul

call :sub1
call :sub2
call :sub3
pause & exit

:sub1
	set count=0
	for /l %%i in (1,1,5) do (
		set /a count+=1
		echo 当前计数 %count%
	)
	exit /b
:sub2
	EnableDelayedExpansion
	echo ╰─> sub2
	set count=0
	for /l %%i in (1,1,5) do (
		set /a count+=1
		echo 当前计数: !count!
	)
	exit /b
:sub3
	setlocal
	echo sub3
	set count=0
	for /l %%i in (1,1,5) do (
		set /a count+=1
		echo 当前计数: !count!
	)
	endlocal
	exit /b