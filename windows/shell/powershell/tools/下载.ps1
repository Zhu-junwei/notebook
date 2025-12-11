# 设置 URL 和目标文件路径
$url = "https://cdn.jsdelivr.net/gh/Zhu-junwei/software/navicat/x64_patch.zip"
$zip = "$env:TEMP\x64_patch.zip"

# 下载文件并显示进度
Write-Host "下载激活补丁..." -ForegroundColor Cyan

$webClient = New-Object System.Net.WebClient

# 绑定进度事件
$progressEvent = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
    $progress = $EventArgs.ProgressPercentage
    Write-Progress -PercentComplete $progress -Status "下载中..." -Activity "正在下载：$url" 
}

# 绑定下载完成事件
$completedEvent = Register-ObjectEvent -InputObject $webClient -EventName DownloadFileCompleted -Action {
    Write-Host "`n下载完成！" -ForegroundColor Green
}

# 开始异步下载
$webClient.DownloadFileAsync($url, $zip)

# 等待下载完成
while ($webClient.IsBusy) {
    Start-Sleep -Seconds 1
}

# 取消事件监听
Unregister-Event -SubscriptionId $progressEvent.Id
Unregister-Event -SubscriptionId $completedEvent.Id

Write-Host "文件已下载到: $zip" -ForegroundColor Green
pause