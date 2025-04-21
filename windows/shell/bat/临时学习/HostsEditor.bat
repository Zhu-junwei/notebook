@ECHO OFF
%Windir%\System32\FLTMC.exe >nul 2>&1 || (
    ECHO CreateObject^("Shell.Application"^).ShellExecute "%~f0", "%PAR1st%", "", "runas", 1 > "%TEMP%\AdminRun.vbs"
    ECHO CreateObject^("Scripting.filesystemobject"^).DeleteFile ^(WScript.ScriptFullName^) >> "%TEMP%\AdminRun.vbs"
    %Windir%\System32\CSCRIPT.exe //Nologo "%TEMP%\AdminRun.vbs"
    Exit /b
)
start "" notepad "%SystemRoot%\system32\drivers\etc\hosts"
exit
