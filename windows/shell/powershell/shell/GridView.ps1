# 在网格窗口显示数据 
Get-Process | Select-Object -First 5 | Out-GridView -Title "进程列表" -PassThru

