$utf8file = "UTF8.txt"
$gb2312file = "GB2312.txt"

Write-Host "生成UTF8文件 : $utf8file"
Set-Content -Value "你还好吗" -Path $utf8file -Encoding UTF8

Write-Host "编码转换 $utf8file -> $gb2312file"
$content = Get-Content $utf8file -Encoding UTF8 -Raw
[IO.File]::WriteAllText($gb2312file, $content, [Text.Encoding]::GetEncoding("GB2312"))

# 删除文件
Write-Host "10s后删除临时文件"
Start-Sleep -Seconds 10
Remove-Item $utf8file
Remove-Item $gb2312file