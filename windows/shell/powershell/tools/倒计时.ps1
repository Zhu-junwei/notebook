# 简单的倒计时计时器
function Start-Timer {
    param (
        [int]$Seconds
    )

    for ($i = $Seconds; $i -ge 0; $i--) {
        Clear-Host
        Write-Host "Time remaining: $i seconds"
        Start-Sleep -Seconds 1
    }

    Write-Host "Time's up!"
    [System.Media.SystemSounds]::Beep.Play()
}

$seconds = Read-Host "Enter the number of seconds for the timer"
Start-Timer -Seconds $seconds

# 暂停终端，等待用户输入
Read-Host "Press Enter to exit"
