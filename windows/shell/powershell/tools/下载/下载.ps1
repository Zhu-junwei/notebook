# 设置 URL 和目标文件路径
$url = "https://cdn.jsdelivr.net/gh/Zhu-junwei/software/navicat/x64_patch.zip"
$zip = "$env:TEMP\x64_patch.zip"

# 创建 WebClient 对象
$webClient = New-Object System.Net.WebClient

# 注册下载进度事件
$progressEvent = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
    $progress = $EventArgs.ProgressPercentage
    $totalBytes = $EventArgs.TotalBytesToReceive
    $bytesReceived = $EventArgs.BytesReceived

    # 计算下载进度的百分比
    $progressPercent = [math]::Round(($bytesReceived / $totalBytes) * 100, 2)

    # 将字节数转换为合适的单位（KB, MB, GB）
    function Convert-Size {
        param ($sizeInBytes)
        if ($sizeInBytes -lt 1MB) {
            return "{0} KB" -f ([math]::Round($sizeInBytes / 1KB, 2))
        } elseif ($sizeInBytes -lt 1GB) {
            return "{0} MB" -f ([math]::Round($sizeInBytes / 1MB, 2))
        } else {
            return "{0} GB" -f ([math]::Round($sizeInBytes / 1GB, 2))
        }
    }

    # 转换已下载和总大小
    $receivedSize = Convert-Size $bytesReceived
    $totalSize = Convert-Size $totalBytes

    # 显示下载进度条并更新当前行
    Write-Progress -PercentComplete $progressPercent -Status "下载中..." -Activity "下载文件: $url" -CurrentOperation "$progressPercent% ($receivedSize / $totalSize)"
}

# 注册下载完成事件
$completedEvent = Register-ObjectEvent -InputObject $webClient -EventName DownloadFileCompleted -Action {
    Write-Host "下载完成！" -ForegroundColor Green
}
# 开始下载文件
Write-Host "开始下载: $url"
$webClient.DownloadFileAsync($url, $zip)
# 等待下载完成
while ($webClient.IsBusy) {
    Start-Sleep -Milliseconds 100
}
Write-Host "文件已下载到: $zip" -ForegroundColor Green

# 清理事件订阅
Unregister-Event -SubscriptionId $progressEvent.Id
Unregister-Event -SubscriptionId $completedEvent.Id

pause