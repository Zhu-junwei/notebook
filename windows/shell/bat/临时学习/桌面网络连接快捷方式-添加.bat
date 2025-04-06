@echo off
mshta VBScript:Execute("Set ws=CreateObject(""WScript.Shell""):Set lnk=ws.CreateShortcut(ws.SpecialFolders(""Desktop"") & ""\网络连接.lnk""):lnk.TargetPath=""shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}"":lnk.Save:close")
echo 快捷方式创建成功！ & pause