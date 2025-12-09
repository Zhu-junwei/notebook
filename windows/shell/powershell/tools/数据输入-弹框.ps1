<#
	图形模糊
#>
Add-Type -AssemblyName Microsoft.VisualBasic
$name=[Microsoft.VisualBasic.Interaction]::InputBox('你的名字','弹框输入',"")

Write-Host "name:$name "

# Wait for user input to exit
Pause