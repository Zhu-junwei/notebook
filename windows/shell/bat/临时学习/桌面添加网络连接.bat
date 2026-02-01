@echo off & chcp 65001 >nul
:desktop_add_network
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ws = New-Object -ComObject WScript.Shell; ^
$desktop = [Environment]::GetFolderPath('Desktop'); ^
$lnk = $ws.CreateShortcut(\"$desktop\网络连接.lnk\"); ^
$lnk.TargetPath = 'shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}'; ^
$lnk.Save()"

exit /b