@echo off & chcp 65001
title Windows IPv4/IPv6端口转发管理工具 
color 0A

:menu
cls
echo ========================================
echo    Windows IPv4/IPv6端口转发管理工具 
echo ========================================
echo  1. 查看所有转发规则 
echo  2. 添加IPv4转发规则 
echo  3. 添加IPv6转发规则 
echo  4. 添加IPv4转IPv6规则 
echo  5. 添加IPv6转IPv4规则 
echo  6. 删除转发规则 
echo  7. 检查防火墙状态 
echo  8. 重置所有规则 
echo  9. 退出程序 
echo ========================================
choice /C 123456789 /N /M "请选择操作（1-9）："

if errorlevel 9 goto :eof
if errorlevel 8 goto resetRules
if errorlevel 7 goto checkFirewall
if errorlevel 6 goto deleteRule
if errorlevel 5 goto addv6tov4
if errorlevel 4 goto addv4tov6
if errorlevel 3 goto addv6tov6
if errorlevel 2 goto addv4tov4
if errorlevel 1 goto showRules

:showRules
cls
echo 当前所有转发规则：
echo ========================================
netsh interface portproxy show all
echo ========================================
pause
goto menu

:addv4tov4
cls
echo 添加IPv4转发规则 
call :addRule v4tov4
goto menu

:addv6tov6
cls
echo 添加IPv6转发规则 
call :addRule v6tov6
goto menu

:addv4tov6
cls
echo 添加IPv4转IPv6规则 
call :addRule v4tov6
goto menu

:addv6tov4
cls
echo 添加IPv6转IPv4规则 
call :addRule v6tov4
goto menu

:addRule
echo ========================================
set /p listenport="输入本地监听端口: "
set /p listenaddr="输入本地监听地址（IPv4默认0.0.0.0，IPv6默认[::]）: "
if "%listenaddr%"=="" (
    if "%1"=="v4tov4" set listenaddr=0.0.0.0
    if "%1"=="v6tov6" set listenaddr=[::]
    if "%1"=="v4tov6" set listenaddr=0.0.0.0
    if "%1"=="v6tov4" set listenaddr=[::]
)
set /p connectport="输入目标端口: "
set /p connectaddr="输入目标地址: "

netsh interface portproxy add %1 listenport=%listenport% listenaddress=%listenaddr% connectport=%connectport% connectaddress=%connectaddr% protocol=tcp

if errorlevel 1 (
    echo 添加规则失败！ 
) else (
    echo 添加规则成功！ 
)
pause
goto :eof

:deleteRule
cls
echo 删除转发规则 
echo ========================================
echo 当前转发规则： 
netsh interface portproxy show all
echo ========================================
set /p listenport="输入要删除的本地监听端口: "
set /p listenaddr="输入要删除的本地监听地址: "

netsh interface portproxy delete v4tov4 listenport=%listenport% listenaddress=%listenaddr%
netsh interface portproxy delete v6tov6 listenport=%listenport% listenaddress=%listenaddr%
netsh interface portproxy delete v4tov6 listenport=%listenport% listenaddress=%listenaddr%
netsh interface portproxy delete v6tov4 listenport=%listenport% listenaddress=%listenaddr%

echo 删除操作完成！ 
pause
goto menu

:checkFirewall
cls
echo 检查防火墙状态 
echo ========================================
netsh advfirewall show allprofiles state
echo ========================================
choice /C YN /N /M "是否需要关闭防火墙？(Y/N)"
if errorlevel 2 goto menu
if errorlevel 1 (
    netsh advfirewall set allprofiles state off
    echo 防火墙已关闭！ 
)
pause
goto menu

:resetRules
cls
echo 正在重置所有转发规则... 
echo ========================================
netsh interface portproxy reset
echo 所有转发规则已重置！ 
pause
goto menu