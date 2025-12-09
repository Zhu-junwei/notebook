<#
    PowerShell 数组使用示例脚本
    文件名：array-demo.ps1
#>

Write-Host "=== 1. 创建数组 ==="
# 方法1：直接创建
$array1 = 1, 2, 3, 4
Write-Host "array1:" $array1

# 方法2：使用 @( )
$array2 = @(10, 20, 30)
Write-Host "array2:" $array2

# 方法3：元素可混合不同类型
$array3 = @("apple", 100, $true)
Write-Host "array3:" $array3


Write-Host "`n=== 2. 查看数组长度 ==="
Write-Host "array1 count:" $array1.Count


Write-Host "`n=== 3. 访问数组元素 ==="
Write-Host "array1[0]:" $array1[0]
Write-Host "array1[1]:" $array1[1]
Write-Host "最后一个元素 (array1[-1]):" $array1[-1]


Write-Host "`n=== 4. 遍历数组 ==="
foreach ($item in $array1) {
    Write-Host "item:" $item
}


Write-Host "`n=== 5. 向数组追加元素 ==="
$array1 += 5
Write-Host "array1 添加一个元素后:" $array1


Write-Host "`n=== 6. 数组切片（子数组） ==="
$sub = $array1[1..3]
Write-Host "array1[1..3]:" $sub


Write-Host "`n=== 7. 过滤数组 ==="
$filtered = $array1 | Where-Object { $_ -gt 2 }
Write-Host "过滤出大于 2 的元素:" $filtered


Write-Host "`n=== 8. 对数组排序 ==="
$sorted = $array1 | Sort-Object
Write-Host "排序结果:" $sorted


Write-Host "`n=== 9. 数组中是否包含某元素 ==="
Write-Host "array1 包含 3 吗? " ($array1 -contains 3)
Write-Host "array1 包含 99 吗? " ($array1 -contains 99)


Write-Host "`n=== 10. 数组转字符串 ==="
$joined = $array1 -join ", "
Write-Host "用逗号连接:" $joined

Write-Host "`n=== 演示结束 ==="
Pause
