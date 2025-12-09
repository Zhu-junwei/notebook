function Test-Internet {
	param (
		[string]$TargetHost = "jd.com",
		[int]$Count = 2
	)
	(Get-NetAdapter | Where-Object {$_.Status -eq "Up"}) -and (Test-Connection $TargetHost -Count $Count -Quiet)
}

# 调用示例
if (Test-Internet) { "可以联网" } else { "无法联网" }
