@echo off & chcp 65001>nul 
:: 禁用Windows无法验证发布者警告提示 
:: 需要管理员权限运行 

:: 检查管理员权限
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' (
    echo 请右键以管理员身份运行此脚本！ 
    pause
    exit /b
)

:: 设置注册表路径
set "regPath=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
set "valueName=LowRiskFileTypes"
set "valueData=.zip;.rar;.nfo;.txt;.exe;.bat;.vbs;.com;.cmd;.reg;.msi;.htm;.html;.gif;.bmp;.jpg;.avi;.mpeg;.mpg;.mp3;.mov;.wav;"

:: 修改注册表 
echo 正在修改注册表以禁用安全警告... 
reg add "%regPath%" /v "%valueName%" /t REG_SZ /d "%valueData%" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo 成功禁用"无法验证发布者"警告提示！ 
    echo 注意：修改可能需要注销或重启后生效 
) else (
    echo 修改失败，请手动尝试以下操作： 
    echo 1. 按Win+R输入regedit 
    echo 2. 导航到: %regPath% 
    echo 3. 新建字符串值: %valueName% 
    echo 4. 设置数值数据为: %valueData% 
)

:: 刷新策略 
echo 正在刷新系统策略... 
gpupdate /force >nul 2>&1 

pause