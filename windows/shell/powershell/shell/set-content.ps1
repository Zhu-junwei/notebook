# 保存数据到文件
$filePath = Join-Path -Path $PSScriptRoot -ChildPath "temp.txt"

Set-Content -Value "Hello" -Path $filePath -Encoding UTF8
# 读取文件
Get-Content -Path $filePath

Write-Host "追加内容`n"
Add-Content -Path $filePath -Value "World"

# 读取文件
Get-Content -Path $filePath

# 删除文件
Remove-Item -Path $filePath
if( -not (Test-Path -Path $filePath)) {
    write-host "文件已删除"
}