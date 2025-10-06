@echo off & chcp 65001>nul
:: 获取管理员权限 
if "%1" neq "runas" mshta vbscript:CreateObject("Shell.Application").ShellExecute("conhost.exe","cmd.exe /c ""%~f0"" runas %*","","runas",1)(window.close)&&exit
shift && cd /d "%~dp0"

:main
echo.
echo  1. 关闭 Windows Defender
echo  2. 开启 Windows Defender 
echo.
set /p submenu_option=请输入你的选择: 
if "%submenu_option%"=="1" (
	goto :disable_wd
) else if "%submenu_option%"=="2" (
	goto :enable_wd
) 
goto :main

:disable_wd
echo 检查篡改防护...
set "TamperProtectionValue="
for /f "usebackq tokens=*" %%a in (`powershell -command "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features').TamperProtection"`) do (
    set "TamperProtectionValue=%%a"
)
if not "%TamperProtectionValue%"=="4" (
	echo 篡改防护已开启 
	start windowsdefender://threatsettings/
	echo 请关闭篡改防护后回车继续.. & pause>nul
	goto :disable_wd
)
:: 从Windows 10 1803版本开始，微软已不再支持此注册表项（虽然键值仍存在但不再生效） 
echo 关闭反间谍软件功能... 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭实时文件扫描...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
:: 在较新 Windows 版本（如 Win10 1809+ 和 Win11）中，微软已移除或限制此类注册表修改方式 
echo 关闭防病毒功能...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiVirus /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭特殊运行模式...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭自动处理行为...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭行为监控...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭实时保护...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f >nul 2>&1
echo 配置签名更新和云保护策略...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v ForceUpdateFromMU /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭 SmartScreen（Windows Defender 之外的安全层）... 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v ShellSmartScreenLevel /t REG_SZ /d "Off" /f >nul 2>&1
echo 关闭 Cloud Protection ^& Sample Submission (云防护组件)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f >nul 2>&1
echo 关闭 Windows 安全性和维护通知 toast 提示(即系统托盘弹出的通知)... 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
echo 关闭 Microsoft Edge 的 SmartScreen ...
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 0 /f >nul 2>&1
echo 关闭 SmartScreen 筛选器（系统级）... 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenPuaEnabled /t REG_DWORD /d 0 /f >nul 2>&1
echo 关闭 Smart App Control（Windows 11 限定）... 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f >nul 2>&1
:: 关闭 本地安全机构保护（LSA Protection） 从 Windows 11 22H2 开始，Microsoft 增加了 UEFI 检测，可能还需要在系统设置中手动“关闭”一次。 
echo 关闭 本地安全机构保护（LSA Protection）...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 0 /f >nul 2>&1
echo 关闭 驱动程序阻止列表...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f >nul 2>&1
echo 关闭 windows安全系统托盘...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v HideSystray /t REG_DWORD /d 1 /f >nul 2>&1
echo 关闭 Windows Defender 的计划任务... 
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable >nul 2>&1
echo Windows Defender 已关闭，需要重启电脑生效。 
set /p reboot=是否现在重启电脑?[Y/n]:
if "%reboot%"=="" set "reboot=Y"
if /i "%reboot%"=="Y" (
	shutdown /r /t 0
)
goto :end

:enable_wd
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRealtimeMonitoring /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiVirus /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableSpecialRunningModes /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRoutinelyTakingAction /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v ShellSmartScreenLevel /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v EnabledV9 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenEnabled /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenPuaEnabled /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /f >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Enable >nul 2>&1
echo Windows Defender已开启，建议重启电脑。 
set /p reboot=是否现在重启电脑?[Y/n]:
if "%reboot%"=="" set "reboot=Y"
if /i "%reboot%"=="Y" (
	shutdown /r /t 0
)
goto :end

:end
endlocal
pause