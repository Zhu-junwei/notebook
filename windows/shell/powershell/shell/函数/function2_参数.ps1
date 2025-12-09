function Add-Numbers {
    param (
        [int]$a,
        [int]$b
    )
    return $a + $b
}

$num1 = 3
$num2 = 5
$result = Add-Numbers -a $num1 -b $num2  
Write-Output "$num1 + $num2 = $result"# 输出 8

Start-Sleep -Seconds 3