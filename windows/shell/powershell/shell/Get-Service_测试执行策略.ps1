# Set-ExecutionPolicy Undefined -Scope CurrentUser 会报错
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser 正常运行
Get-Service -Name W32Time
Start-Sleep -Seconds 3