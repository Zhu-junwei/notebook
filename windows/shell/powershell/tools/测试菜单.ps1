# =============================
# PowerShell 菜单示例
# =============================

function Show-DateTime {
    Write-Host "`n当前日期和时间：$(Get-Date)`n"
    Write-Host "按回车继续..." -NoNewline
	[void][System.Console]::ReadKey($true)
}

function List-Files {
    Write-Host "`n当前目录文件列表："
    Get-ChildItem | ForEach-Object { Write-Host $_.Name }
    Write-Host ""
    Pause
}

function Show-Menu {
    Clear-Host
    Write-Host "=============================="
    Write-Host "         主菜单"
    Write-Host "=============================="
    Write-Host "1. 显示当前日期和时间"
    Write-Host "2. 列出当前目录文件"
    Write-Host "3. 退出"
}

# =============================
# 主循环
# =============================
do {
    Show-Menu
    $choice = Read-Host "请输入选项数字"
    
    switch ($choice) {
        "1" { Show-DateTime }
        "2" { List-Files }
        "3" { exit }
    }

} while ($true)
