Write-Output "使用位置参数函数，无需参数名"
function Add {
    param ($x, $y)
    $x + $y
}

$num1 = 3
$num2 = 5
$result = Add $num1 $num2  
Write-Output "$num1 + $num2 = $result"# 输出 8

Start-Sleep -Seconds 3