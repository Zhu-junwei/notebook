@echo off & chcp 65001>nul & setlocal enabledelayedexpansion

for /f "tokens=1 delims=#" %%a in ('"prompt #$E# & echo on & for %%b in (1) do rem"') do (set "esc=%%a")

set /a "time_r=0"
set /a "time_e=0"
set /a "time_d=50"
echo.
echo Text - 1

set /p "=!esc!7" <nul
call :loop
set /p "=!esc!8" <nul

echo.
echo Text - 2
pause

:loop
set "char1="
set "char2="
set /a "time_e+=1"
set /a "time_sc+=2"
set /a "time_out=!random!%%2"
set /a "time_r=!time_d!-!time_e!"

for /l %%a in (1,1,!time_e!) do (set "char1=!char1!#")
for /l %%a in (1,1,!time_r!) do (set "char2=!char2! ")

set /p "=!esc!8!esc![1G!esc![K!char1!!char2! - !time_sc!%%" <nul

timeout /t !time_out! >nul 2>nul
if "!time_e!" equ "!time_d!" (exit /b)
goto :loop