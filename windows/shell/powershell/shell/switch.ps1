while ($true) {
    Clear-Host
    Write-Host "1. 红色 2. 绿色 3. 蓝色 0. 退出" -ForegroundColor Cyan

    $choice = (Read-Host "请输入选项数字").Trim()

    switch ($choice) {
        "1" { Write-Host "红色信息" -ForegroundColor Red; Start-Sleep 1 }
        "2" { Write-Host "绿色信息" -ForegroundColor Green; Start-Sleep 1 }
        "3" { Write-Host "蓝色信息" -ForegroundColor Blue; Start-Sleep 1 }
        "0" { Write-Host "程序已退出。" -ForegroundColor Gray; return }
        default { Write-Host "无效选项"; Start-Sleep 1 }
    }
}
