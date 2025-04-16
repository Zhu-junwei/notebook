@echo off
mode con:cols=80 lines=20
set nowcg=当前未修改
:menu
set key=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private
set valueName=autosetup
set openValue=1
set closeValue=0


REM 检查注册表键值是否存在
reg query "%key%" /v "%valueName%" >nul 2>&1

if %errorlevel% equ 0 (
  REM 如果键值存在，检查它的值
  for /f "tokens=3" %%i in ('reg query "%key%" /v "%valueName%"') do (
    if %%i equ %openValue% (
      set p_autosetup=开启
    ) else (
      set p_autosetup=关闭
    )
  )
) else (
  REM 如果键值不存在，默认为开启
  set p_autosetup=开启
)

echo autosetup的状态为：%p_autosetup%

rem 查询默认打印机名称和端口
for /f "tokens=2 delims==" %%a in ('wmic printer where default^="true" get portname /value') do set df_printer_port=%%a
for /f "tokens=2 delims==" %%a in ('wmic printer where default^="true" get name /value') do set df_printer=%%a
echo Default Printer: %df_printer% on port %df_printer_port%
title AppStore-打印机维护工具
cls
echo ================================
echo         打印机维护工具
echo ================================
echo 0. 打开旧的"硬件和打印机文件夹"
echo 1. 打开高级共享设置
echo 2. 开启LPD打印机共享功能
echo 3. 禁用网络连接设备的自动设置(网络发现) 当前状态为：%p_autosetup%
echo 4. 设置默认打印机 当前: %df_printer%  端口:%df_printer_port%
echo 5. 添加LPD打印机
echo 6. 手动添加打印机
echo 7. 清理打印任务
echo 8. 打印管理[方便]
echo 9. 修复SMB共享[备用方案，风险!不推荐]
echo c. 修改计算机名并立即生效，无须重启! [ 当前:%computername% ]  %nowcg% %hostname%
echo x. 退出

set /p choice=请输入选项的数字：

if "%choice%"=="0" start "" shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}&&goto menu
if "%choice%"=="1" start "" control.exe /name Microsoft.NetworkAndSharingCenter /page Advanced&&goto menu
if "%choice%"=="2" goto AddLPD
if "%choice%"=="3" REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" /v "AutoSetup" /t REG_DWORD /d 0 /f&&goto menu
if "%choice%"=="4" call :set_printer&&goto menu
if "%choice%"=="5" call :add_lpd_printer&&goto menu
if "%choice%"=="6" start "" rundll32 printui.dll,PrintUIEntry /il&&goto menu
if "%choice%"=="7" call :del_jobs&&goto menu
if "%choice%"=="8" start "" %systemroot%\system32\printmanagement.msc&&goto menu
if "%choice%"=="9" call :fix_smb_printer&&goto menu
if "%choice%"=="c" call :cgname&&goto menu
if "%choice%"=="x" exit

echo 无效的选项，请重试。
pause
goto menu



:AddLPD
@echo 开启LPD打印相关功能……
@echo off

ver | find "6.1." > nul && set os=win7
ver | find "10.0." > nul && set os=win10

if "%os%"=="win7" (
    echo Windows 7 detected
    REM 执行 Win7 系统下的操作
    call :win7
   
) else if "%os%"=="win10" (
    echo Windows 10 detected
    REM 执行 Win10 系统下的操作
    call :win10
 
) else (
    echo Unsupported OS version
)

pause




:win10
rem windows10
dism /online /enable-feature /featurename:"Printing-Foundation-InternetPrinting-Client" /all
dism /online /enable-feature /featurename:"Printing-Foundation-LPDPrintService" /all
dism /online /enable-feature /featurename:"Printing-Foundation-LPRPortMonitor" /all
exit /b

:win7
rem windows7
dism /online /enable-feature /featurename:"Printing-Foundation-Features" /norestart
dism /online /enable-feature /featurename:"Printing-Foundation-LPDPrintService" /norestart
dism /online /enable-feature /featurename:"Printing-Foundation-LPRPortMonitor" /norestart
dism /online /enable-feature /featurename:"Printing-Foundation-InternetPrinting-Client" /norestart
exit /b


:set_printer
setlocal enabledelayedexpansion

rem 列出所有打印机
echo "正在枚举所有打印机..."
set counter=0
for /f "tokens=2 delims==" %%a in ('wmic printer get name /value^|find "="') do (
  set /a counter+=1
  set printer[!counter!]=%%a
  echo !counter!. %%a
)

rem 用户选择默认打印机
set /p choice="请输入要设置为默认打印机的编号："
if %choice% gtr %counter% exit /b
set defaultprinter=!printer[%choice%]!
echo 将 "%defaultprinter%" 设置为默认打印机...
rundll32 printui.dll,PrintUIEntry /y /n "%defaultprinter%"

rem 删除多余的打印机
set skipdelete=
set /p deletelabel="是否删除不需要的打印机？（y/n）："
if /i "%deletelabel%"=="y" (
    set skipdelete=1
    echo 正在准备删除多余的打印机...
    for /f "tokens=2 delims==" %%a in ('wmic printer get default /value^|find "="') do (
        set defaultprinter=%%a
    )
    for /f "tokens=2 delims==" %%a in ('wmic printer get name^|find ":"') do (
        if /i not "%%a"=="%defaultprinter%" (
            rundll32 printui.dll,PrintUIEntry /dl /n "%%a"
            echo 已删除打印机 "%%a".
        )
    )
)

if not defined skipdelete (
    echo 因您选择了“否”，将保留所有打印机.
)

echo 打印机设置完成。
timeout 1 /nobreak
exit /b

:add_lpd_printer
echo 正在配置防火墙...
netsh advfirewall firewall add rule name="LPR Port" dir=in action=allow protocol=TCP localport=515
netsh advfirewall firewall add rule name="LPD Port" dir=in action=allow protocol=TCP localport=721-731
echo 防火墙已经配置完成！
set /p ip=请输入要添加的LPD打印机ip:
set /p queue=请输入要添加的打印队列(共享)名称(不能用空格):
set /p p_inf=请输入要添加的驱动文件路径(以inf结尾):
rundll32 printui.dll,PrintUIEntry /if /b "%queue%" /f "%p_inf%" /r "IP_%ip%" /m "LPD Printer" /z
echo 操作完成!
exit /b


:del_jobs
echo 停止打印服务...
echo Y|net stop spooler
echo 删除所有打印任务...
del /Q /F /S "%SystemRoot%\System32\spool\PRINTERS\*"
echo 启动打印服务
net start spooler
echo 打印任务清理完成!
timeout 1 /nobreak
exit /b

:fix_smb_printer
rem 要通过注册表切换网络打印设置
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
rem 要启用侦听传入连接
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcProtocols /t REG_DWORD /d 0x7 /f
rem 要强制执行 Kerberos 身份验证，
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v ForceKerberosForRpc /t REG_DWORD /d 1 /f
rem 其它注册表(别人提供)
Reg add "HKLM\System\CurrentControlSet\Control\Print" /v "RpcAuthnLevelPrivacyEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v "RestrictDriverInstallationToAdministrators" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v "RpcUseNamedPipeProtocol" /t REG_DWORD /d 1 /f
:: 启用不安全的来宾登录
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f
:: 禁用通信数字签名（始终）
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 0 /f

gpupdate /force
echo 开启SMB1 支持
DISM /Online /Enable-Feature /FeatureName:SMB1Protocol /norestart
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 0 /f 
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnableForcedLogoff /t REG_DWORD /d 0 /f
exit /b


:cgname
set now=chobit%date:~2,2%%time:~9,10%
echo 当前计算机名为%computername%,    按回车改为%now%
set /p hostname=请输入修改后的计算机名:
if "%hostname%"=="" set hostname=%now%
echo 修改计算机名为：%hostname% 按回车修改
@echo 修改中……
@echo off

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v "ComputerName" /t REG_SZ /d "%hostname%" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v "ComputerName" /t REG_SZ /d "%hostname%" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d "%hostname%" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d "%hostname%" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AltDefaultDomainName" /t REG_SZ /d "%hostname%" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /t REG_SZ /d "%hostname%" /f
echo y|net stop WlanSvc>nul
echo y|net stop Wcmsvc>nul
echo y|net start Wcmsvc>nul
echo y|net start WlanSvc>nul
@echo 修改计算机名为%hostname%完成！
set nowcg=已修改为
echo 测试是否生效的方法:在其它计算机访问\\%hostname%或ping %hostname%
exit /b