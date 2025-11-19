if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb runAs; exit}

Write-Host "加载移动磁盘...`n" -ForegroundColor Green
$usbDisks = Get-Disk | Where-Object {$_.BusType -eq "USB"}

if ($usbDisks.Count -eq 0) {
    Write-Host "没有发现移动磁盘。" -ForegroundColor Red
} else {
	foreach ($disk in $usbDisks) {
		$diskNumber = $disk.Number
		$diskName = $disk.FriendlyName
		$totalSize = $disk.Size  # 直接获取 Size 属性
		
		# 格式化为易读的格式
		if ($totalSize -ge 1GB) {
			$sizeFormatted = "{0:N2} GB" -f ($totalSize / 1GB)
		} else {
			$sizeFormatted = "{0:N2} MB" -f ($totalSize / 1MB)
		}
		
		
		# 获取该磁盘的所有盘符
		$driveLetters = Get-Partition -DiskNumber $diskNumber | 
					   Where-Object {$_.DriveLetter} | 
					   ForEach-Object {$_.DriveLetter + ":"}
		
		# 将盘符数组转换为字符串
		$driveLettersStr = if ($driveLetters.Count -gt 0) {
			"[" + ($driveLetters -join ", ") + "]"
		} else {
			"[无盘符]"
		}
		
		Write-Host "正在脱机磁盘 $diskNumber ($diskName) $driveLettersStr $sizeFormatted ..." -ForegroundColor Yellow
		
		$diskPartScript = @"
			SELECT DISK $diskNumber
			OFFLINE DISK
			EXIT
"@
		$diskPartScript | diskpart | Out-Null
		
		Write-Host "✓ 磁盘 $diskNumber $driveLettersStr 已成功脱机`n" -ForegroundColor Green
	}

	Write-Host "`n所有移动磁盘脱机操作完成！" -ForegroundColor Cyan
}
Start-Sleep -Seconds 3