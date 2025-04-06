@echo off &title  _ CMD 设置 PE _
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
PUSHD %~dp0
::获取管理员权限

set mode=
::改成0 加入启动菜单，每次启动系统时都可以选择
::改成1 一次性启动
::其他参数则：显示菜单页面。
if /i "%mode%"=="0" goto:mode0
if /i "%mode%"=="1" goto:mode1

:mode
ECHO.
ECHO.         按数字 0  把PE加入启动列表
ECHO.
ECHO.         按数字 1  进入一次性PE
ECHO.
choice /C:01 /N /M ">输入你的选择："
if errorlevel  2 goto:mode1
if errorlevel  1 goto:mode0

:mode0
cls
Call :bcdedit
bcdedit /displayorder %Guid% -addlast >nul 2>&1
::把PE加入启动列表。
bcdedit /timeout 5 
::设置等待时间为 5 秒（可更改）
cls &echo.&echo  PE启动项添加完成。按任意键退出。&pause >nul&exit

:mode1
cls
Call :bcdedit
bcdedit /bootsequence %Guid% >nul 2>&1
::重启后进入此PE（一次性的）。
cls&echo.&echo 设置完成，按任意键重启，并进入PE。&pause >nul
::删除此行，立即重启进入PE。
shutdown -r -t 0
::立即重启
exit /b

:bcdedit
cls&echo.&echo 正在处理……
md "C:\PE" >nul 2>&1
::在C盘新建PE文件夹
if not exist boot.sdi (cls &echo.&echo 未找到boot.sdi文件，请把文件和此脚本放一起。按任意键退出。&pause >nul&exit)
xcopy boot.sdi "C:\PE" /Y /Q >nul 2>&1
::复制boot.sdi文件到"C:\PE"文件夹
if not exist boot.wim (cls &echo.&echo 未找到boot.wim镜像，请把镜像和此脚本放一起。按任意键退出。&pause >nul&exit)
xcopy boot.wim "C:\PE" /Y /Q >nul 2>&1
::复制boot.wim镜像到"C:\PE"文件夹（boot.wim自己准备）
for /f "delims={,} tokens=2" %%a in ('bcdedit /create /d "PE" -application osloader') do set Guid={%%a}
::用bdedit创建启动项，导出GUID序列号，赋值给变量Guid
bcdedit /set {ramdiskoptions} ramdisksdidevice partition=C: >nul 2>&1
::设置RAM磁盘镜像所在分区为C:盘（可更改）
bcdedit /set {ramdiskoptions} ramdisksdipath \PE\boot.sdi >nul 2>&1
::设置RAM磁盘SDI路径，可以自定义。
bcdedit /set %Guid% device ramdisk="[C:]\PE\boot.wim,{ramdiskoptions}" >nul 2>&1
::启动设备（可更改）
bcdedit /set %Guid% osdevice ramdisk="[C:]\PE\boot.wim,{ramdiskoptions}" >nul 2>&1
::系统启动设备（设置和启动设备一样就行，可更改）
bcdedit /set %Guid% locale zh-CN >nul 2>&1
::区域设置中国
bcdedit /set %Guid% systemroot \windows >nul 2>&1
::系统根目录
bcdedit /set %Guid% detecthal Yes >nul 2>&1
::检测HAL（硬件抽象层），如Yes（一般用于PE）
bcdedit /set %Guid% winpe Yes >nul 2>&1
::是否windows PE，如Yes（只有是PE时才需要此参数）
exit /b