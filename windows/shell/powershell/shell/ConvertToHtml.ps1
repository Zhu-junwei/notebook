# 保存数据到文件
$filePath = Join-Path -Path $PSScriptRoot -ChildPath "index.html"

Get-Process | Select-Object name,id,path -First 5 | ConvertTo-Html | Out-File $filePath

Start-Process $filePath

# 删除文件
Remove-Item -Path $filePath
if( -not (Test-Path -Path $filePath)) {
    write-host "文件已删除"
}
