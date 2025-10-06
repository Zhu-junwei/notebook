@echo off & chcp 65001 >nul
setlocal enabledelayedexpansion

echo %date% %time%
:: 配置目标文件和文件夹 
::set "target=D:\systemfile\Pictures\BingWallpapers\1\file5300.jpg"
set "folder=D:\systemfile\Pictures\BingWallpapers\1"

:: 提取 target 文件名 
for %%A in ("%target%") do set "target_name=%%~nxA"

:: 初始化  
set "prev="
set "found="
set "next="
set /a count=0
set "rand="

:: 一遍遍历，最新文件在前 
for /f "delims=" %%F in ('dir /b /a:-d /o:-d "%folder%\*.bmp" "%folder%\*.jpg" "%folder%\*.jpeg" "%folder%\*.png" 2^>nul') do (
    set /a count+=1

    :: 动态随机选择（蓄水池采样，每个文件被选概率相等）
    set /a r=%random% %% !count!
    if !r! EQU 0 set "rand=%folder%\%%~F"
	
	:: 第一个和最后一个文件 
	if not defined first_file set "first_file=%folder%\%%~F"
	set "last_file=%folder%\%%~F"

    :: 上/下文件逻辑 
    if not defined found (
        if /i "%%F"=="%target_name%" (
            set "found=1"
        ) else (
            set "prev=%folder%\%%~F"
        )
    ) else (
        if not defined next (
            set "next=%folder%\%%~F"
        )
    )
)
if not defined found if defined first_file set "prev=%first_file%"
if not defined next if defined first_file set "next=%first_file%"
if not defined prev set "prev=%last_file%"

:: 补位 
if not defined prev set "prev=%target%"
if not defined next set "next=%target%"
if not defined rand set "rand=%target%"

:: 输出 
echo 上一个文件: %prev%
echo 当前文件: %target%
echo 下一个文件: %next%
echo 随机文件: %rand%
echo %date% %time%
