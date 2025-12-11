
#if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb runAs; exit}

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
	Write-Host (Indent-Text "         脚本管家") -ForegroundColor Yellow
	Write-Host ("=" * $width) -ForegroundColor Cyan
	Write-Host
	Write-Host (Indent-Text "1. Windows管理小工具") -ForegroundColor Green
	Write-Host
	Write-Host (Indent-Text "2. JetBrains 全家桶激活") -ForegroundColor Green
	Write-Host
	Write-Host (Indent-Text "3. Navicat Premium 激活") -ForegroundColor Green
	Write-Host
	Write-Host (Indent-Text "0. 退出")
	Write-Host
	Write-Host ("=" * $width) -ForegroundColor Cyan
}

# ----------------
# 运行远程脚本
# ----------------
function Invoke-ScriptFromUrl {
    param (
        [string]$url,
        [switch]$IsAdmin
    )
    if ($IsAdmin) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex ((irm $url) -replace '^\uFEFF', '')`"" -Verb RunAs
    } else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex ((irm $url) -replace '^\uFEFF', '')`""
    }
}

$running = $true
while ($running) {
	Show-Menu
	$choice = Read-Host "请输入选项数字"
	switch ($choice) {
		"1" { 
			$url = "https://raw.githubusercontent.com/Zhu-junwei/Windows-Manage-Tool/master/WindowsManageTool.bat"
			irm $url -OutFile "$env:TEMP\WindowsManageTool.bat"
			Start-Process cmd.exe "/c `"$env:TEMP\WindowsManageTool.bat`"" 
		}
		"2" {
			$url = "https://raw.githubusercontent.com/Zhu-junwei/notebook/master/windows/shell/powershell/tools/JetBrains全家桶激活.ps1"
			Invoke-ScriptFromUrl $url -IsAdmin
		}
		"3" { 
			$url = "https://raw.githubusercontent.com/Zhu-junwei/notebook/master/windows/shell/powershell/tools/navicat_patch.ps1"
			Invoke-ScriptFromUrl $url
		}
		"0" { $running = $false }
	}
}