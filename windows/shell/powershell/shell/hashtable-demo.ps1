<#
    PowerShell 哈希表使用示例脚本
    文件名：hashtable-demo.ps1
#>

Write-Host "=== 1. 创建哈希表 ==="
# 方法1：常规键值对写法
$person = @{
    Name = "Alice"
    Age = 25
    City = "New York"
}
Write-Host "person:" $person

# 方法2：空哈希表后添加
$emptyHash = @{}
$emptyHash["Key1"] = "Value1"
$emptyHash["Key2"] = "Value2"
Write-Host "emptyHash:" $emptyHash


Write-Host "`n=== 2. 访问哈希表内容 ==="
Write-Host "Name:" $person["Name"]
Write-Host "Age:" $person.Age    # 点号访问
Write-Host "City:" $person.City


Write-Host "`n=== 3. 修改哈希表 ==="
$person.Age = 30
$person["City"] = "Los Angeles"
Write-Host "修改后的 person.City:" $person.City


Write-Host "`n=== 4. 添加键值对 ==="
$person["Job"] = "Engineer"
Write-Host "添加 Job 后的 person.Job:" $person.Job


Write-Host "`n=== 5. 删除键 ==="
$person.Remove("Job")
Write-Host "删除 Job 后的 person:" $person


Write-Host "`n=== 6. 判断键是否存在 ==="
Write-Host "是否包含 Age 键? " ($person.ContainsKey("Age"))
Write-Host "是否包含 Salary 键? " ($person.ContainsKey("Salary"))


Write-Host "`n=== 7. 遍历哈希表 ==="
foreach ($key in $person.Keys) {
    Write-Host "$key = $($person[$key])"
}

# 或更完整的写法
Write-Host "`n遍历 Key-Value 对:"
foreach ($item in $person.GetEnumerator()) {
    Write-Host "$($item.Key): $($item.Value)"
}


Write-Host "`n=== 8. 获取所有键与值 ==="
Write-Host "所有键:" $person.Keys
Write-Host "所有值:" $person.Values


Write-Host "`n=== 9. 哈希表转 JSON ==="
$json = $person | ConvertTo-Json
Write-Host "JSON 格式:" $json


Write-Host "`n=== 10. 嵌套哈希表（对象结构） ==="
$server = @{
    Host = "localhost"
    Port = 3306
    Credentials = @{
        User = "root"
        Password = "123456"
    }
}

Write-Host "server.Host:" $server.Host
Write-Host "server.Credentials.User:" $server.Credentials.User


Write-Host "`n=== 示例结束 ==="
Pause
