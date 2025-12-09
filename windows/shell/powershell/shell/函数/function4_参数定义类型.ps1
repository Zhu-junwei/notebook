Write-Output "使用位置参数函数，无需参数名"
function Get-Square {
    param ([int]$num)
    return $num * $num
}

$num = 6
$result = Get-Square -num $num
Write-Output "$num * $num = $result"# 输出 36

Start-Sleep -Seconds 3