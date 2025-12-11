# Show-Colors.ps1
# 显示 PowerShell 支持的前景色

# 获取所有控制台颜色枚举
$colors = [System.Enum]::GetValues([System.ConsoleColor])

Write-Host "PowerShell 可用的前景色示例：" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan

foreach ($color in $colors) {
    # 显示颜色名字，用这个颜色打印
    Write-Host ("{0,-15}" -f $color) -ForegroundColor $color
}

pause