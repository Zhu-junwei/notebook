@echo off & chcp 65001>nul
setlocal enabledelayedexpansion
net session >nul 2>&1 || powershell -NoP -C "Start-Process -FilePath '%~f0' -Verb RunAs" && exit

set "SERVICE=openlist"
set "SERVICE_NAME=OpenList"
set "PORT=5244"
color 2e

:main
cls
mode con cols=60 lines=30
title 服务管理工具 - OpenList
echo.
echo			    【 OpenList管理工具 】 
echo.
echo ------------------------------------------------------------
echo				1.开启 &echo.
echo				2.关闭 &echo.
echo				3.状态 &echo.
echo				4.打开页面 &echo.
echo				5.开机自启动 &echo.
echo       		 	6 手动启动 &echo.
echo       		 	7.退出  &echo.
echo ------------------------------------------------------------
set "c="
choice /C 1234567 /N /M "请输入您的选择:"
if errorlevel 7 exit
if errorlevel 6 call :set_demand
if errorlevel 5 call :set_autostartup
if errorlevel 4 call :start_web
if errorlevel 3 call :check_status
if errorlevel 2 call :stop_service
if errorlevel 1 call :start_service
goto main

:start_service
echo 启动 %SERVICE_NAME%... 
sc start %SERVICE% >nul 2>&1
echo %SERVICE_NAME% 已启动。 & timeout /t 3
exit /b

:stop_service
echo 停止 %SERVICE_NAME%... 
sc stop %SERVICE% >nul 2>&1
echo %SERVICE_NAME% 已停止。 & timeout /t 3
exit /b

:check_status
echo 检查 %SERVICE_NAME%... 
for /f "tokens=4" %%a in ('sc query %SERVICE% ^| findstr "STATE"') do set service_state=%%a
echo 当前状态：%service_state%
timeout /t 3
exit /b

:start_web
start "" "http://localhost:%PORT%"
exit /b

:set_autostartup
sc config openlist start=auto& timeout /t 3
exit /b

:set_demand
sc config openlist start=demand & timeout /t 3
exit /b
