Set fso = CreateObject("Scripting.FileSystemObject")
vbsDir = fso.GetParentFolderName(WScript.ScriptFullName)

Set ws = CreateObject("WScript.Shell")
ws.CurrentDirectory = vbsDir
ws.Run """change_desktop_background.bat""", 0
