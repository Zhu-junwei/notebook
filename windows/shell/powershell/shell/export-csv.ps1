# 保存数据到文件
$filePath = Join-Path -Path $PSScriptRoot -ChildPath "temp.csv"

Get-Process | Select-Object -First 5 | Export-Csv -Path $filePath
Write-Host "文件已经导出"

# 追加
Get-Process | Select-Object -Skip 5 -First 5 | Export-Csv -Path $filePath -Append

# 删除文件
Remove-Item -Path $filePath
if( -not (Test-Path -Path $filePath)) {
    write-host "文件已删除"
}