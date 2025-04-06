@echo off
setlocal EnableDelayedExpansion

FOR /F "tokens=3*" %%A IN ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden') DO (
    set Hidden=%%A
)

IF "!Hidden!"=="0x1" (
    echo 当前为“显示”，正在设置为“隐藏”...
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 0 /f
) ELSE (
    echo 当前为“隐藏”，正在设置为“显示”...
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
)

endlocal
pause