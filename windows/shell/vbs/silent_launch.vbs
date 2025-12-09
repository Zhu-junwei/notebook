If WScript.Arguments.Count = 0 Then WScript.Quit
target = Chr(34) & WScript.Arguments(0) & Chr(34)
args = ""
For i = 1 To WScript.Arguments.Count - 1
    args = args & " " & Chr(34) & WScript.Arguments(i) & Chr(34)
Next
cmd = target & args
CreateObject("WScript.Shell").Run cmd, 0, False