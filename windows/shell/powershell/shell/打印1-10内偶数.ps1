<# 打印1-10之间的偶数 #>

for ( $i = 1; $i -le 10; $i++ )
{
    $x = $i % 2
    if($x -eq 0)
    {
        Write-Host $i
    }
}