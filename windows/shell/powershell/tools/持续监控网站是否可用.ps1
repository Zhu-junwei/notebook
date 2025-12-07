$url = "http://baidu.com"  # 替换成你要检查的网站
$interval = 5  # 检测间隔（秒）

while ($true) {
    $response = try { (Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -ErrorAction Stop).StatusCode } catch { $_.Exception.Response.StatusCode.value__ }

    if ($response -eq 200) {
        Write-Host "$(Get-Date -Format 'HH:mm:ss') 网站返回 200，正常访问！" -ForegroundColor Green
        #[System.Console]::Beep(1000, 500)  # 发出提示音
		[System.Media.SystemSounds]::Beep.Play()
		#Start-Job -ScriptBlock { [System.Media.SystemSounds]::Beep.Play() } | Out-Null
    } else {
        Write-Host "$(Get-Date -Format 'HH:mm:ss') 网站返回 $response，可能有问题！" -ForegroundColor Red
    }
    Start-Sleep -Seconds $interval  # 等待X秒后再次检测
}