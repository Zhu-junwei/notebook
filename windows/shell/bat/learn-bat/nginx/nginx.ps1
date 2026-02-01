# 设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-NginxRoot {

    $nginxExe = $null
    # 1. 脚本所在目录 - NGINX_HOME - PATH
    if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'nginx.exe'))) {
        $nginxExe = Join-Path $PSScriptRoot 'nginx.exe'
    } elseif (($env:NGINX_HOME -or ($env:NGINX_HOME = [Environment]::GetEnvironmentVariable("NGINX_HOME","User"))) -and (Test-Path (Join-Path $env:NGINX_HOME 'nginx.exe'))) {
        $nginxExe = Join-Path $env:NGINX_HOME 'nginx.exe'
    } else {
        $cmd = Get-Command nginx.exe -ErrorAction SilentlyContinue
        if ($cmd) {
            $nginxExe = $cmd.Source
        }
    }

    if (-not $nginxExe) {
        Write-Host "`n[错误] 未能找到 nginx.exe" -ForegroundColor Red
        exit 1
    }

    # 4. Windows nginx 的真实“根” = nginx.exe 所在目录
    $root = Split-Path -Parent (Resolve-Path $nginxExe)

    return $root
}


# 执行方法并初始化全局变量
$p = Get-NginxRoot
$exe = Join-Path $p "nginx.exe"

function Get-NginxVersion {
    $rawV = & $exe -v 2>&1
    if ($rawV -match "nginx/(\d+\.\d+\.\d+)") { 
        return $matches[1] 
    }
    return "未知"
}
$version = Get-NginxVersion

# 开机自启状态
function Get-AutoStartStatus {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $runName = "NginxAutoStart"
    # 检查注册表是否存在该键值
    $val = Get-ItemProperty -Path $regPath -Name $runName -ErrorAction SilentlyContinue
    return $val -ne $null
}

# 获取 NGINX 监听端口的函数
function Get-NginxPorts {
    $procs = Get-Process "nginx" -ErrorAction SilentlyContinue
    if (-not $procs) { return "未监听" }
    
    $pids_list = $procs.Id
    # 使用 netstat 查询 LISTENING 状态的端口
    $netstat = netstat -ano | Select-String "LISTENING"
    $foundPorts = @()
    
    foreach ($line in $netstat) {
        # 这里的变量名改为 $p_id，避免冲突
        foreach ($p_id in $pids_list) {
            # 正则匹配：确保 PID 在行尾
            if ($line -match "\s+$p_id$") {
                $parts = $line.ToString().Trim() -split '\s+'
                if ($parts.Count -ge 2) {
                    $address = $parts[1]
                    $port = ($address -split ':')[-1]
                    $foundPorts += $port
                }
            }
        }
    }
    
    if ($foundPorts.Count -gt 0) {
        return ($foundPorts | Select-Object -Unique) -join ", "
    }
    return "启动中..."
}
# 带打断功能的等待函数
function Wait-OrBreak {
    param([int]$Seconds)
    
    Write-Host "" # 换行拉开距离
    $startPos = [Console]::CursorLeft
    $topPos = [Console]::CursorTop

    # --- 场景 1: 如果 Seconds 为 0，实现无限期停在那 ---
    if ($Seconds -eq 0) {
        Write-Host " [ 按任意键返回... ] " -ForegroundColor Gray -NoNewline
        # 清除可能残余的按键，然后静静等待
        while ([System.Console]::KeyAvailable) { $null = [System.Console]::ReadKey($true) }
        $null = [System.Console]::ReadKey($true)
        Write-Host ""
        return
    }

    # --- 场景 2: 如果 Seconds > 0，执行动态倒计时 ---
    for ($i = $Seconds; $i -gt 0; $i--) {
        [Console]::SetCursorPosition($startPos, $topPos)
        # 这里的空格是为了覆盖位位数变化带来的残留
        Write-Host " [ $i s 后自动返回，或按任意键返回... ]   " -ForegroundColor Gray -NoNewline
        
        for ($j = 0; $j -lt 10; $j++) {
            if ([System.Console]::KeyAvailable) {
                $null = [System.Console]::ReadKey($true) 
                Write-Host ""
                return
            }
            Start-Sleep -Milliseconds 100
        }
    }
    Write-Host ""
}

while ($true) {
    Clear-Host
    $procs = Get-Process "nginx" -ErrorAction SilentlyContinue
    $ports = Get-NginxPorts
    $isAutoStart = Get-AutoStartStatus
    
    # --- 状态面板 ---
    Write-Host "`n                          Nginx 管理工具 " -ForegroundColor Cyan
    Write-Host " ==============================================================================" -ForegroundColor DarkGray
    Write-Host -NoNewline "  Nginx版本 : "
	Write-Host " $version" -ForegroundColor Cyan
	Write-Host -NoNewline "  开机自启  : "
	if ($isAutoStart) {
        Write-Host " ▶ 已开启" -ForegroundColor Green
    } else {
        Write-Host " ■ 未开启" -ForegroundColor DarkGray
    }
    Write-Host -NoNewline "  当前状态  : "
    if ($procs) {
        Write-Host " ▶ 运行中" -ForegroundColor Green -NoNewline
        Write-Host " (端口: $ports)" -ForegroundColor Yellow
    } else {
        Write-Host " ■ 已停止" -ForegroundColor Red
    }
    Write-Host " ==============================================================================`n" -ForegroundColor DarkGray
    
    # --- 竖向菜单 ---
    Write-Host "                  [1] 启动" -ForegroundColor Green
    Write-Host "                  [2] 停止" -ForegroundColor Red
    Write-Host "                  [3] 打开页面`n"
    Write-Host "                  [4] 编辑配置"
    Write-Host "                  [5] 重载配置"
    Write-Host "                  [6] 检查配置语法"
    Write-Host "                  [7] 查看错误日志`n"
    Write-Host "                  [8] 设置开机自启" -ForegroundColor Cyan
    Write-Host "                  [9] 取消开机自启`n"
    Write-Host "                  [0] 退出程序`n" -ForegroundColor DarkGray
    Write-Host " ------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " 请直接按下按键执行操作..." -ForegroundColor Gray
    
    # --- 捕获单键输入 ---
    if ([System.Console]::KeyAvailable) {
        # 清除之前可能残余的按键缓冲
        $null = [System.Console]::ReadKey($true)
    }
    $key = [Console]::ReadKey($true)
    $opt = $key.KeyChar
    
    Write-Host "`n [收到指令: $opt]" -ForegroundColor DarkGray

    switch ($opt) {
        "1" { 
            if (-not $procs) { 
                Start-Process -FilePath $exe -ArgumentList "-p",$p -WindowStyle Hidden
                Write-Host " [√] 启动指令已发出。" -ForegroundColor Green
            } else {
				Write-Host " [√] NGINX 已运行" -ForegroundColor Cyan
			}
			Start-Sleep -Seconds 1
        }
        "2" { 
            if ($procs) {
                & $exe -p $p -s quit
                Write-Host " [√] 正在停止 NGINX..." -ForegroundColor Yellow
            } else {
				Write-Host " [√] NGINX未在运行中" -ForegroundColor Cyan
			}
			Start-Sleep -Seconds 1
        }
		"3" {
            if (-not $procs) {
                Write-Host " [!] NGINX 未运行，无法访问网页。" -ForegroundColor Red
                Start-Sleep -Seconds 1
            } else {
                # 从 $ports 字符串（例如 "80, 8080"）重新拆分为数组
                $portList = $ports -split ", "
                
                if ($portList.Count -eq 1) {
                    # 只有一个端口，直接打开
                    $url = "http://localhost:$($portList[0])"
                    Write-Host " [√] 正在打开: $url" -ForegroundColor Blue
                    Start-Process $url
                    Start-Sleep -Milliseconds 500
                } else {
                    # 多个端口，提供选择
                    Write-Host "`n 检测到多个监听端口，请选择要访问的端口:" -ForegroundColor Cyan
                    for ($i = 0; $i -lt $portList.Count; $i++) {
                        Write-Host "  [$($i + 1)] 端口: $($portList[$i])" -ForegroundColor Gray
                    }
                    Write-Host "  [0] 返回菜单" -ForegroundColor DarkGray
                    
                    # 捕获单键选择
                    $pKey = [Console]::ReadKey($true)
                    $pIdx = [int]($pKey.KeyChar.ToString()) - 1
                    
                    if ($pIdx -ge 0 -and $pIdx -lt $portList.Count) {
                        $url = "http://localhost:$($portList[$pIdx])"
                        Write-Host " [√] 正在打开: $url" -ForegroundColor Blue
                        Start-Process $url
                    }
                }
            }
        }
        "4" {
            $confPath = Join-Path $p "conf\nginx.conf"
            if (Test-Path $confPath) {
                Write-Host " [√] 正在调用系统编辑器打开配置文件..." -ForegroundColor Cyan
                Invoke-Item $confPath
                Start-Sleep -Seconds 1
            } else {
                Write-Host " [!] 未找到配置文件: $confPath" -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
        "5" { 
            if ($procs) {
                & $exe -p $p -s reload
                Write-Host " [√] 配置重载指令已发送。" -ForegroundColor Cyan
            } else {
                Start-Process nginx -ArgumentList "-p `"$p`"" -WindowStyle Hidden
                Write-Host " [√] NGINX 未运行，已执行启动。" -ForegroundColor Green
            }
			Start-Sleep -Seconds 1
        }
        "6" { 
            Write-Host " --- 语法检查结果 ---" -ForegroundColor DarkGray
            & $exe -p "$p" -t 
            Wait-OrBreak -Seconds 5
        }
        "7" {
            $logPath = Join-Path $p "logs\error.log"
            if (Test-Path $logPath) {
                Write-Host " --- 错误日志最后10行 ---" -ForegroundColor Magenta
                Get-Content $logPath -Tail 10
            } else {
                Write-Host " [!] 未找到日志文件: $logPath" -ForegroundColor Yellow
            }
			Wait-OrBreak 0
        }
		"8" {
            # 定义启动项名称和执行命令
            $runName = "NginxAutoStart"
            # 这里建议自启 Nginx 进程本身
            $runCmd = "`"$exe`" -p `"$p`""
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $runName -Value $runCmd
                Write-Host " [√] 已添加开机自启（当前用户）。" -ForegroundColor Green
            } catch {
                Write-Host " [!] 设置失败，请尝试以管理员身份运行。" -ForegroundColor Red
            }
            Start-Sleep -Seconds 2
        }
        "9" {
            $runName = "NginxAutoStart"
            try {
                Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $runName -ErrorAction SilentlyContinue
                Write-Host " [√] 已取消开机自启。" -ForegroundColor Yellow
            } catch {
                Write-Host " [!] 操作失败。" -ForegroundColor Red
            }
            Start-Sleep -Seconds 2
        }
        "0" { exit }
        default { continue } # 无效按键立即刷新
    }
}