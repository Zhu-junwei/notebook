@echo off & chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 设置当前脚本的本地更新日期（用于比较） 
set "LOCAL_UPDATED=20250524"
set "LOCAL_VER=v2.0.0"

:: GitHub 原始地址和压缩包地址
set "RAW_URL=https://raw.githubusercontent.com/Zhu-junwei/Windows-Manage-Tool/master/Windows管理小工具.bat"
set "ZIP_URL=https://github.com/Zhu-junwei/Windows-Manage-Tool/archive/refs/heads/master.zip"
set "ZIP_PATH=%TEMP%\WindowsManageTool.zip"
set "TEMP_HEAD=%TEMP%\_wmtool_head.tmp"

:: 桌面路径
set "DESKTOP=%USERPROFILE%\Desktop"
set "DEST_FILE=%DESKTOP%\Windows管理小工具.bat"

:: 下载头部以检测版本
curl -s -r 0-512 "%RAW_URL%" -o "%TEMP_HEAD%"
if not exist "%TEMP_HEAD%" (
    echo 错误：无法下载远程文件！请检查链接。
    pause
    exit /b 1
)

:: 提取版本号和更新时间
set "REMOTE_UPDATED="
set "REMOTE_VER="

for /f "delims=" %%A in ('findstr /i "updated=" "%TEMP_HEAD%"') do (
    for /f "tokens=2 delims==" %%B in ("%%A") do set "REMOTE_UPDATED=%%~B"
)

for /f "delims=" %%A in ('findstr /i "rversion=" "%TEMP_HEAD%"') do (
    for /f "tokens=2 delims==" %%B in ("%%A") do set "REMOTE_VER=%%~B"
)

:: 去除引号（如果有）
:: set "REMOTE_UPDATED=!REMOTE_UPDATED:"=!"
:: set "REMOTE_VER=!REMOTE_VER:"=!"

echo.
echo 本地版本号：%LOCAL_VER%
echo 本地更新号：%LOCAL_UPDATED%
echo 远程版本号：!REMOTE_VER!
echo 远程更新号：!REMOTE_UPDATED!
echo.

:: 比较版本
if not defined REMOTE_UPDATED (
    echo 无法获取远程更新日期，放弃更新。
    pause
    exit /b
)

if %LOCAL_UPDATED% GEQ !REMOTE_UPDATED! (
    echo ✅ 已是最新版本，无需更新。
    pause
    exit /b
)

:: 下载 ZIP 并提取 bat 文件
echo 检测到新版本，正在下载到桌面...
curl -L -o "%ZIP_PATH%" "%ZIP_URL%"
if not exist "%ZIP_PATH%" (
    echo 下载 zip 文件失败。
    pause
    exit /b
)

:: 解压指定文件（仅 .bat） 
:: 解压指定文件（仅 Windows管理小工具.bat） 
powershell -nologo -noprofile -command ^
  "$zipPath = '%ZIP_PATH%';" ^
  "$outPath = '%DEST_FILE%';" ^
  "Add-Type -AssemblyName System.IO.Compression.FileSystem;" ^
  "$zip = [IO.Compression.ZipFile]::OpenRead($zipPath);" ^
  "$entry = $zip.Entries | Where-Object { $_.FullName -eq 'Windows-Manage-Tool-master/Windows管理小工具.bat' };" ^
  "if ($entry) {" ^
  "  $stream = $entry.Open();" ^
  "  $fileStream = [System.IO.File]::Create($outPath);" ^
  "  $stream.CopyTo($fileStream);" ^
  "  $fileStream.Close(); $stream.Close();" ^
  "  Write-Host '更新完成：' $outPath" ^
  "} else {" ^
  "  Write-Host '未找到目标文件。'" ^
  "}" ^
  "$zip.Dispose()"


:: 清理临时文件
::del "%ZIP_PATH%" >nul 2>nul
::del "%TEMP_HEAD%" >nul 2>nul

pause
exit /b
