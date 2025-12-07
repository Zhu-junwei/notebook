# 设置日志文件
$logFile = "C:\Screenshots\log.txt"
function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# 检查并创建任务计划
$taskName = "AutoScreenshot"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if (-not $taskExists) {
    Write-Log "检查任务计划：任务不存在，开始创建。"
    $scriptPath = Join-Path $PSScriptRoot "screenshot.ps1"
    # 添加 -WindowStyle Hidden 参数
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
    # 设置触发器：从现在开始，每分钟重复
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    try {
        Register-ScheduledTask -TaskName $taskName `
                              -Action $action `
                              -Trigger $trigger `
                              -Settings $settings `
                              -Description "每分钟自动截图" `
                              -Force
        Write-Log "任务计划创建成功：$taskName"
        Write-Host "任务计划已创建：$taskName"
    } catch {
        Write-Log "任务计划创建失败：$_"
        Write-Host "创建任务计划失败：$_"
        exit
    }
} else {
    Write-Log "任务计划已存在：$taskName"
    Write-Host "任务计划已存在：$taskName"
}

# 设置保存截图的文件夹
$saveFolder = "C:\Screenshots"
if (!(Test-Path $saveFolder)) {
    New-Item -ItemType Directory -Path $saveFolder
}

# 获取当前时间，用于命名文件
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$savePath = "$saveFolder\screenshot_$timestamp.png"

# 添加运行时日志
Write-Log "脚本开始执行，尝试截图。"

# 检查屏幕可用性并截图
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    # 检查是否在远程会话中
    $isTerminalSession = [System.Windows.Forms.SystemInformation]::TerminalServerSession
    Write-Log "终端会话状态：$isTerminalSession"

    # 获取主屏幕
    $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
    if (-not $primaryScreen) {
        throw "未找到主屏幕"
    }

    # 获取主屏幕的边界
    $bounds = $primaryScreen.Bounds
    Write-Log "主屏幕分辨率: $($bounds.Width)x$($bounds.Height), 位置: ($($bounds.X), $($bounds.Y))"

    # 检查主屏幕边界是否有效
    if ($bounds.Width -le 0 -or $bounds.Height -le 0) {
        throw "主屏幕分辨率无效：宽度或高度小于等于0"
    }

    # 从注册表获取缩放比例
    $regPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
    $regValue = Get-ItemProperty -Path $regPath -Name "AppliedDPI" -ErrorAction SilentlyContinue
    if ($regValue -and $regValue.AppliedDPI) {
        $dpi = $regValue.AppliedDPI
        $scale = $dpi / 96.0
    } else {
        # 如果注册表中没有 AppliedDPI，则使用默认值 1
        $scale = 1.0
    }
    Write-Log "缩放比例: $scale"

    # 检查缩放比例是否有效
    if ($scale -le 0) {
        throw "缩放比例无效：小于等于0"
    }

    # 调整截图尺寸
    $scaledWidth = [int]($bounds.Width * $scale)
    $scaledHeight = [int]($bounds.Height * $scale)
    Write-Log "调整后的截图尺寸: ${scaledWidth}x${scaledHeight}"

    # 检查调整后的尺寸是否有效
    if ($scaledWidth -le 0 -or $scaledHeight -le 0) {
        throw "调整后的截图尺寸无效：宽度或高度小于等于0"
    }

    # 创建 Bitmap 并截图
    $bitmap = New-Object System.Drawing.Bitmap $scaledWidth, $scaledHeight
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # 调整 CopyFromScreen 的参数
    $graphics.CopyFromScreen($bounds.X, $bounds.Y, 0, 0, $bitmap.Size, [System.Drawing.CopyPixelOperation]::SourceCopy)
    $bitmap.Save($savePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()

    Write-Log "截图成功：$savePath (分辨率: ${scaledWidth}x${scaledHeight})"
    Write-Host "截图已保存至：$savePath"
} catch {
    Write-Log "截图失败：$_"
    Write-Host "截图失败：$_"
}