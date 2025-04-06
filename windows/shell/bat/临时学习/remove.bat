@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: 设置新的文件夹路径
set target_root="D:\NewLocations"

:: 创建目标根目录（如果不存在）
echo Creating target root directory if it doesn't exist...
mkdir %target_root%

:: 设置文件夹名称
set desktop_name="Desktop"
set download_name="Downloads"
set documents_name="Documents"
set pictures_name="Pictures"
set music_name="Music"
set videos_name="Videos"

:: 删除目标文件夹中的现有内容（如果需要）
echo Deleting existing target folders if they exist...
rd /s /q "%target_root%\%desktop_name%"
rd /s /q "%target_root%\%download_name%"
rd /s /q "%target_root%\%documents_name%"
rd /s /q "%target_root%\%pictures_name%"
rd /s /q "%target_root%\%music_name%"
rd /s /q "%target_root%\%videos_name%"

:: 创建目标文件夹（如果不存在）
echo Creating target folders...
mkdir "%target_root%\%desktop_name%"
mkdir "%target_root%\%download_name%"
mkdir "%target_root%\%documents_name%"
mkdir "%target_root%\%pictures_name%"
mkdir "%target_root%\%music_name%"
mkdir "%target_root%\%videos_name%"

:: 修改并移动桌面文件夹
echo Moving Desktop folder...
move "%USERPROFILE%\Desktop" "%target_root%\%desktop_name%"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d "%target_root%\%desktop_name%" /f

:: 修改并移动下载文件夹
echo Moving Downloads folder...
move "%USERPROFILE%\Downloads" "%target_root%\%download_name%"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Downloads /t REG_EXPAND_SZ /d "%target_root%\%download_name%" /f

:: 修改并移动文档文件夹
echo Moving Documents folder...
move "%USERPROFILE%\Documents" "%target_root%\%documents_name%"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%target_root%\%documents_name%" /f

:: 修改并移动图片文件夹
echo Moving Pictures folder...
move "%USERPROFILE%\Pictures" "%target_root%\%pictures_name%"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Pictures /t REG_EXPAND_SZ /d "%target_root%\%pictures_name%" /f

:: 修改并移动音乐文件夹
echo Moving Music folder...
move "%USERPROFILE%\Music" "%target_root%\%music_name%"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Music /t REG_EXPAND_SZ /d "%target_root%\%music_name%" /f

:: 修改并移动视频文件夹
echo Moving Videos folder...
move "%USERPROFILE%\Videos" "%target_root%\%videos_name%"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Video /t REG_EXPAND_SZ /d "%target_root%\%videos_name%" /f

echo File locations and contents have been updated. Please restart your computer for the changes to take effect.
pause
