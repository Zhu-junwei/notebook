@echo off
setlocal enabledelayedexpansion

set "text=这是一句需要设置颜色的示例文字"

:: 使用 PowerShell 获取字符串长度
for /f %%a in ('powershell -command "$str='%text%'; Write-Host $str.Length"') do set str_len=%%a

set /a target_idx_3=str_len - 3
set /a target_idx_4=str_len - 4

powershell -Command "$text='%text%';$blue=[ConsoleColor]::Blue;$red=[ConsoleColor]::Red;0..($text.Length-1)|%%{if($_ -eq %target_idx_3% -or $_ -eq %target_idx_4%){Write-Host -NoNewline -ForegroundColor Red $text[$_]}else{Write-Host -NoNewline -ForegroundColor Blue $text[$_]}}"

endlocal
pause >nul