@echo off&setlocal enabledelayedexpansion&title Windows11设置工具箱&color 0B&set "prompt=账户与登录管理 隐私与权限控制 网络与连接配置 系统优化与维护 个性化与显示设置 开发者与高级功能"
:M
cls
echo ================================
echo    Windows 系统设置直达工具
echo ================================
call :C prompt
echo !n!. 退出
call :CHOICE !e!!n!
goto :%ERRORLEVEL%
if %ERRORLEVEL%==7 exit
:1
set "options=signinoptions signinoptions-dynamiclock signinoptions-launchfaceenrollment signinoptions-launchfingerprintenrollment yourinfo sync emailandaccounts"
set "items=登录选项（PIN/生物识别） 动态锁设置 面部识别设置 指纹录入设置 账户信息查看 同步设置 应用账户管理"
goto :SUB
:2
set "options=privacy-microphone privacy-webcam privacy-location privacy-calendar privacy-contacts privacy-speechtyping"
set "items=麦克风权限 摄像头权限 定位服务 日历访问 联系**限 语音输入权限"
goto :SUB
:3
set "options=network-status network-proxy network-mobilehotspot network-cellular regionlanguage-chsime-pinyin regionlanguage-chsime-wubi"
set "items=网络状态 代理设置 移动热点 蜂窝网络 拼音输入法 五笔输入法"
goto :SUB
:4
set "options=windowsupdate windowsupdate-options activation storagesense storagepolicies recovery"
set "items=系统更新检查 高级更新设置 激活状态查看 存储空间清理 文件清理策略 恢复选项"
goto :SUB
:5
set "options=personalization-background themes colors taskbar personalization-start"
set "items=桌面壁纸设置 主题管理 窗口颜色调整 任务栏设置 开始菜单布局"
goto :SUB
:6
set "options=developers windowsdefender recovery display-advancedgraphics regionlanguage-chsime-pinyin-udp regionlanguage-chsime-wubi-udp"
set "items=开发者模式 安全中心 系统恢复选项 高级显示设置 拼音高级设置 五笔高级设置"
goto :SUB
:SUB
cls
echo ================================
call :JQ %ERRORLEVEL% prompt "echo ●▽●. "
echo ================================
call :C items
echo !n!. 返回主菜单
call :CHOICE !e!!n!
if %ERRORLEVEL%==!n! goto M
call :JQ %ERRORLEVEL% options "start ms-settings:"
goto :SUB
:C
set e=
set n=0
for %%i in (!%1!)do set/a n+=1&set "e=!e!!n!"&call :JQ !n! %1 "echo !n!. "
set/a n+=1
exit /b
:JQ
for /f "tokens=%1 delims= " %%i in ("!%2!")do if not "%%i"=="" %~3%%i
exit /b
:CHOICE
choice /c %1 /n /m "请选择操作编号："
exit/b