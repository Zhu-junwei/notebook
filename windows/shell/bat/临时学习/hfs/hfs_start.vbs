Set WshShell = CreateObject("WScript.Shell")

' 检查是否有传递参数
If WScript.Arguments.Count > 0 Then
    port = WScript.Arguments.Item(0) ' 获取传递的端口参数
Else
    port = 8068 ' 默认端口
End If

' 使用 Shell 来启动程序，并且在后台运行
WshShell.Run """HFS.exe"" --port " & port, 0, False

Set WshShell = Nothing
