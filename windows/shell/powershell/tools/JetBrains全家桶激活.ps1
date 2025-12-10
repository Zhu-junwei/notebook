# run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb runAs; exit}

Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
	Clear-Host

	# 设置缩进空格数
	$indent = 5
	$width = 50

	# 辅助函数：左对齐显示文字，但有缩进
	function Indent-Text($text) {
		return (" " * $indent) + $text
	}

	Write-Host ("=" * $width) -ForegroundColor Cyan
	Write-Host (Indent-Text "    JetBrains 全家桶激活脚本") -ForegroundColor Yellow
	Write-Host ("=" * $width) -ForegroundColor Cyan
	Write-Host
	Write-Host (Indent-Text "1. 激活`n") -ForegroundColor Green
	Write-Host (Indent-Text "2. 取消激活`n")
	Write-Host (Indent-Text "3. 下载离线激活包`n")
	Write-Host (Indent-Text "0. 退出`n")
	Write-Host ("=" * $width) -ForegroundColor Cyan
}

function Download-OfflinePackage {
	$url = "https://ckey.run/offline"
	$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
	$output = [System.IO.Path]::Combine($desktopPath, "ckey_run.zip")
	Write-Host "`n正在下载离线激活包到桌面，请稍候..."
	try {
		Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
		Write-Host "`n下载完成：$output"
	} catch {
		Write-Host "`n下载失败：$($_.Exception.Message)"
	}
	Pause
}

$running = $true
while ($running) {
	Show-Menu
	$choice = Read-Host "请输入选项数字"
	switch ($choice) {
		"1" { irm ckey.run | iex }
		"2" { irm ckey.run/uninstall | iex }
		"3" { Download-OfflinePackage }
		"0" { $running = $false }
	}
}