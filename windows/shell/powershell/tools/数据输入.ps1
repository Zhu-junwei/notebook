$name=Read-Host "请输入名字"
$password=Read-Host "请输入密码" -AsSecureString

# 转成明文
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
)

Write-Host "name:$name , password:$plainPassword"

# Wait for user input to exit
Pause