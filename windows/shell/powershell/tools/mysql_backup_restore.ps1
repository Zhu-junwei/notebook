<#
.SYNOPSIS
MySQL/MariaDB 备份还原工具 (冷备份) - 简化版
 
.DESCRIPTION
专为电脑小白设计的MySQL备份还原工具:
1. 使用明文密码输入
2. 详细错误信息显示
3. 智能路径检测
4. 清晰的操作提示
#>
 
# 初始化配置（增加端口号）
$global:mysqlExe = $null
$global:mysqldumpExe = $null
$global:currentDir = $PSScriptRoot
$global:connectionParams = @{
    Host = "localhost"
    Port = 3306  # 默认MySQL端口
    User = "root"
    Password = "123456"
}
 
# 修复的暂停函数 - 兼容所有环境
function Pause {
    Write-Host "`n按 Enter 键继续..." -ForegroundColor DarkGray
    # 使用兼容性更好的方法
    $null = Read-Host
}
 
# 安全执行命令函数 - 增强错误处理
function Invoke-SafeCommand {
    param(
        [string]$Command,
        [string[]]$Arguments,
        [switch]$ShowCommand
    )
     
    # 构建安全显示的命令（隐藏密码）
    $displayArguments = $Arguments -replace "--password=.*", "--password=******"
    $displayCommand = "$Command $($displayArguments -join ' ')"
     
    if ($ShowCommand) {
        Write-Host "`n[执行命令]" -ForegroundColor DarkGray
        Write-Host $displayCommand -ForegroundColor DarkCyan
        Write-Host ""
    }
     
    try {
        # 创建临时文件
        $stdoutFile = Join-Path $global:currentDir "temp_stdout.txt"
        $stderrFile = Join-Path $global:currentDir "temp_stderr.txt"
         
        # 使用 Start-Process 避免路径解析问题
        $process = Start-Process -FilePath $Command `
            -ArgumentList $Arguments `
            -NoNewWindow `
            -Wait `
            -PassThru `
            -RedirectStandardOutput $stdoutFile `
            -RedirectStandardError $stderrFile
         
        $output = Get-Content $stdoutFile -Raw -ErrorAction SilentlyContinue
        $errorOutput = Get-Content $stderrFile -Raw -ErrorAction SilentlyContinue
         
        # 清理临时文件
        Remove-Item $stdoutFile -Force -ErrorAction SilentlyContinue
        Remove-Item $stderrFile -Force -ErrorAction SilentlyContinue
         
        if ($process.ExitCode -ne 0) {
            # 返回错误信息
            return @{
                Success = $false
                Output = $output
                Error = $errorOutput
                ExitCode = $process.ExitCode
            }
        }
         
        # 返回成功结果
        return @{
            Success = $true
            Output = $output
            Error = $null
            ExitCode = 0
        }
    }
    catch {
        return @{
            Success = $false
            Output = $null
            Error = "执行出错: $_"
            ExitCode = -1
        }
    }
}
 
# 查找MySQL可执行文件
function Find-MySqlTools {
    # 1. 检查当前目录
    $mysqlPath = Join-Path $global:currentDir "mysql.exe"
    $mysqldumpPath = Join-Path $global:currentDir "mysqldump.exe"
     
    if ((Test-Path $mysqlPath) -and (Test-Path $mysqldumpPath)) {
        $global:mysqlExe = $mysqlPath
        $global:mysqldumpExe = $mysqldumpPath
        return $true
    }
     
    # 2. 检查环境变量中的路径
    $paths = $env:PATH -split ';'
     
    # 3. 添加常见安装路径
    $commonPaths = @(
        "C:\Program Files\MariaDB*\bin",
        "C:\Program Files\MySQL\MySQL Server*\bin",
        "C:\Program Files (x86)\MariaDB*\bin",
        "C:\Program Files (x86)\MySQL\MySQL Server*\bin"
    )
     
    $searchPaths = $paths + $commonPaths | Where-Object { $_ -ne $null } | Select-Object -Unique
     
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $mysqlPath = Join-Path $path "mysql.exe"
            $mysqldumpPath = Join-Path $path "mysqldump.exe"
             
            if (Test-Path $mysqlPath) { 
                $global:mysqlExe = $mysqlPath
            }
             
            if (Test-Path $mysqldumpPath) { 
                $global:mysqldumpExe = $mysqldumpPath
            }
             
            if ($global:mysqlExe -and $global:mysqldumpExe) {
                return $true
            }
        }
    }
     
    # 4. 通过Windows服务查找
    try {
        $mysqlServices = Get-CimInstance Win32_Service -Filter "Name LIKE '%mysql%'" -ErrorAction Stop |
                          Where-Object { $_.PathName -match "mysqld" }
         
        if ($mysqlServices) {
            foreach ($service in $mysqlServices) {
                # 更健壮的路径提取方法
                $binPath = if ($service.PathName -match '"(.*?)\\bin\\.*?"') {
                    $matches[1] + "\bin"
                } else {
                    $service.PathName.Trim('"') -replace '(.*\\bin).*', '$1'
                }
                 
                $mysqlPath = Join-Path $binPath "mysql.exe"
                $mysqldumpPath = Join-Path $binPath "mysqldump.exe"
                 
                if (Test-Path $mysqlPath) { 
                    $global:mysqlExe = $mysqlPath
                }
                 
                if (Test-Path $mysqldumpPath) { 
                    $global:mysqldumpExe = $mysqldumpPath
                }
                 
                if ($global:mysqlExe -and $global:mysqldumpExe) {
                    return $true
                }
            }
        }
    }
    catch {
        # 忽略服务查询错误
    }
     
    return $false
}
 
# 测试数据库连接（增加端口参数）
function Test-MySqlConnection {
    param(
        [string]$hostName,
        [int]$port,
        [string]$userName,
        [string]$password
    )
     
    # 使用内置的mysql系统数据库测试连接
    $arguments = @(
        "-h", $hostName,
        "-P", $port.ToString(),
        "-u", $userName,
        "--password=$password",
        "-D", "mysql",  # 指定内置的系统数据库
        "-e", """SELECT 1;"""  # 简单查询测试
    )
     
    $result = Invoke-SafeCommand -Command $global:mysqlExe -Arguments $arguments -ShowCommand
     
    if (-not $result.Success) {
        if ($result.Error) {
            Write-Host "`n连接错误: $($result.Error)" -ForegroundColor Red
        }
        return $false
    }
     
    return $true
}
 
# 获取用户数据库列表（增加端口参数）
function Get-UserDatabases {
    # 使用内置的mysql系统数据库执行查询
    $arguments = @(
        "-h", $global:connectionParams.Host,
        "-P", $global:connectionParams.Port.ToString(),
        "-u", $global:connectionParams.User,
        "--password=$($global:connectionParams.Password)",
        "-D", "mysql",  # 指定内置的系统数据库
        "-e", """SHOW DATABASES;"""
    )
     
    $result = Invoke-SafeCommand -Command $global:mysqlExe -Arguments $arguments -ShowCommand
     
    if (-not $result.Success) {
        Write-Host "`n获取数据库列表失败: $($result.Error)" -ForegroundColor Red
        return @()
    }
     
    $databases = $result.Output -split "`r`n" | Select-Object -Skip 1 | Where-Object { $_ -ne "" }
     
    # 过滤系统数据库
    $systemDbs = @("information_schema", "mysql", "performance_schema", "sys")
    return $databases | Where-Object { $_ -notin $systemDbs }
}
 
# 备份数据库 - 增强错误处理（增加端口参数）
function Backup-Database {
    $databases = Get-UserDatabases
     
    if (-not $databases) {
        Write-Host "没有找到可备份的数据库!" -ForegroundColor Red
        return
    }
     
    # 显示数据库列表
    Write-Host "`n请选择要备份的数据库:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $databases.Count; $i++) {
        Write-Host "$($i+1). $($databases[$i])"
    }
     
    # 用户选择
    $choice = Read-Host "`n输入编号 (1-$($databases.Count))"
    $dbIndex = [int]$choice - 1
     
    if ($dbIndex -lt 0 -or $dbIndex -ge $databases.Count) {
        Write-Host "选择无效!" -ForegroundColor Red
        return
    }
     
    $dbName = $databases[$dbIndex]
    $backupFile = "$global:currentDir\$dbName-$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
     
    # 执行备份
    Write-Host "`n正在备份数据库 $dbName ..." -ForegroundColor Yellow
     
    $arguments = @(
        "-h", $global:connectionParams.Host,
        "-P", $global:connectionParams.Port.ToString(),
        "-u", $global:connectionParams.User,
        "--password=$($global:connectionParams.Password)",
        "--databases", $dbName,
        "--result-file=`"$backupFile`""
    )
     
    # 显示进度
    Write-Host "备份中，请稍候..." -ForegroundColor Gray
     
    $result = Invoke-SafeCommand -Command $global:mysqldumpExe -Arguments $arguments -ShowCommand
     
    if ($result.Success -and (Test-Path $backupFile)) {
        $fileSize = [math]::Round((Get-Item $backupFile).Length / 1MB, 2)
        Write-Host "备份成功! 文件位置: $backupFile" -ForegroundColor Green
        Write-Host "文件大小: $fileSize MB" -ForegroundColor Green
    } else {
        Write-Host "`n备份失败! ×" -ForegroundColor Red
         
        # 显示详细错误信息
        if ($result.Error) {
            Write-Host "错误信息: $($result.Error)" -ForegroundColor Red
        } elseif ($result.Output) {
            Write-Host "输出信息: $($result.Output)" -ForegroundColor Yellow
        }
         
        Write-Host "`n请检查以下可能的问题:" -ForegroundColor Yellow
        Write-Host "1. 数据库名称是否正确? ($dbName)" -ForegroundColor Yellow
        Write-Host "2. 用户名和密码是否有权限访问该数据库?" -ForegroundColor Yellow
        Write-Host "3. 服务器是否运行正常? ($($global:connectionParams.Host):$($global:connectionParams.Port))" -ForegroundColor Yellow
        Write-Host "4. 当前目录是否有写入权限? ($global:currentDir)" -ForegroundColor Yellow
        Write-Host "5. MySQL服务是否已启动?" -ForegroundColor Yellow
         
        # 提供诊断建议
        Write-Host "`n诊断建议:" -ForegroundColor Cyan
        Write-Host "1. 手动测试连接: mysql -h $($global:connectionParams.Host) -P $($global:connectionParams.Port) -u $($global:connectionParams.User) -p" -ForegroundColor Cyan
        Write-Host "2. 检查数据库是否存在: SHOW DATABASES;" -ForegroundColor Cyan
        Write-Host "3. 尝试手动备份: mysqldump -h $($global:connectionParams.Host) -P $($global:connectionParams.Port) -u $($global:connectionParams.User) -p --databases $dbName > test.sql" -ForegroundColor Cyan
    }
}
 
# 恢复数据库 - 使用更可靠的方法（增加端口参数）
function Restore-Database {
    $backupFiles = Get-ChildItem -Path $global:currentDir -Filter *.sql |
                   Where-Object { $_.Name -notlike "*_structure.sql" -and $_.Name -notlike "*_data.sql" }
 
    if (-not $backupFiles) {
        Write-Host "`n当前文件夹没有找到备份文件!" -ForegroundColor Red
        return
    }
 
    # 显示备份文件列表
    Write-Host "`n请选择要恢复的备份文件:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $backupFiles.Count; $i++) {
        Write-Host "$($i+1). $($backupFiles[$i].Name)"
    }
 
    $choice = Read-Host "`n输入编号 (1-$($backupFiles.Count))"
    $fileIndex = [int]$choice - 1
    if ($fileIndex -lt 0 -or $fileIndex -ge $backupFiles.Count) {
        Write-Host "选择无效!" -ForegroundColor Red
        return
    }
 
    $backupFile = $backupFiles[$fileIndex].FullName
    $sqlContent = Get-Content -Path $backupFile -Raw
 
    # 提取原数据库名（第一个 USE `dbname`;）
    $match = [regex]::Match($sqlContent, 'USE\s+`([^`]+)`\s*;')
    if (-not $match.Success) {
        Write-Host "无法从备份文件中提取数据库名!" -ForegroundColor Red
        return
    }
 
    $originalDbName = $match.Groups[1].Value
    Write-Host "`n检测到原数据库名: $originalDbName" -ForegroundColor Cyan
 
    # 循环输入新数据库名，直到不重复
    $targetDbName = ""
    $existingDbs = Get-UserDatabases
    do {
        $targetDbName = Read-Host "请输入新数据库名称（不能已存在）"
        if ([string]::IsNullOrWhiteSpace($targetDbName)) {
            Write-Host "输入不能为空，请重新输入!" -ForegroundColor Yellow
            continue
        }
        if ($targetDbName -in $existingDbs) {
            Write-Host "数据库 '$targetDbName' 已存在，请重新输入!" -ForegroundColor Yellow
        }
    } while ([string]::IsNullOrWhiteSpace($targetDbName) -or ($targetDbName -in $existingDbs))
 
    # 读取所有行
    $lines = Get-Content -Path $backupFile -Encoding utf8
     
    # 只处理前30行，进行简单替换
    for ($i = 0; $i -lt [Math]::Min(30, $lines.Count); $i++) {
        $lines[$i] = $lines[$i] -replace [regex]::Escape($originalDbName), $targetDbName
    }
     
    # 写回完整内容
    $sqlContent = $lines -join "`r`n"
 
    # 保存临时文件（带新数据库名）
    $tempFile = "$targetDbName-restored.sql"
    $sqlContent | Out-File -FilePath $tempFile -Encoding utf8
 
    Write-Host "`n正在执行恢复脚本..." -ForegroundColor Yellow
     
    # 创建错误日志文件
    $errorLogFile = Join-Path $global:currentDir "$targetDbName-RestoreErrors.log"
     
    # 使用 --force 参数确保即使有错误也继续执行
    $arguments = @(
        "-h", $global:connectionParams.Host,
        "-P", $global:connectionParams.Port.ToString(),
        "-u", $global:connectionParams.User,
        "--password=$($global:connectionParams.Password)",
        "--force",  # 即使有SQL错误也继续执行
        "-D", "mysql",  # 连接到系统数据库
        "-e", "`"source $tempFile`""
    )
     
    # 记录开始时间
    $startTime = Get-Date
     
    # 执行恢复命令
    $result = Invoke-SafeCommand -Command $global:mysqlExe -Arguments $arguments -ShowCommand
     
    # 将错误输出保存到日志文件
    if (-not [string]::IsNullOrWhiteSpace($result.Error)) {
        $result.Error | Out-File -FilePath $errorLogFile -Encoding default
    }
     
    # 清理临时文件
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
     
    # 计算执行时间
    $elapsedTime = (Get-Date) - $startTime
    $totalSeconds = [math]::Round($elapsedTime.TotalSeconds, 2)
     
    # 处理执行结果
    if ($result.Success) {
        Write-Host "`n √恢复完成! 执行时间: $totalSeconds 秒" -ForegroundColor Green
    } else {
        Write-Host "`n ×恢复过程中出现错误! 执行时间: $totalSeconds 秒" -ForegroundColor Yellow
    }
     
    # 显示错误日志信息（如果有）
    if (Test-Path $errorLogFile) {
        $errorCount = (Get-Content $errorLogFile | Where-Object { $_ -match "ERROR" }).Count
        Write-Host "`n恢复过程中发现 $errorCount 个错误" -ForegroundColor Red
        Write-Host "详细错误日志已保存到: $errorLogFile" -ForegroundColor Yellow
         
        if ($errorCount -gt 0) {
            Write-Host "`n最后5条错误信息:" -ForegroundColor Red
            Get-Content $errorLogFile | Select-Object -Last 5 | ForEach-Object {
                Write-Host $_ -ForegroundColor Red
            }
        }
    }
     
    # 验证表数量
    $verify = Invoke-SafeCommand -Command $global:mysqlExe -Arguments @(
        "-h", $global:connectionParams.Host,
        "-P", $global:connectionParams.Port.ToString(),
        "-u", $global:connectionParams.User,
        "--password=$($global:connectionParams.Password)",
        $targetDbName,
        "-e", """SHOW TABLES;"""
    )
 
    if ($verify.Success) {
        $tables = $verify.Output -split "`r`n" | Where-Object { $_ -ne "" }
        Write-Host "`n数据库 '$targetDbName' 包含 $($tables.Count) 个表。" -ForegroundColor Green
    } else {
        Write-Host "`n无法验证数据库表数量。" -ForegroundColor Yellow
    }
}
 
# 主菜单
function Show-MainMenu {
    Clear-Host
    Write-Host "`n"
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " MySQL数据库备份还原工具 (小白专用版) " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "当前连接:"
    Write-Host "服务器: $($global:connectionParams.Host)"
    Write-Host "端口号: $($global:connectionParams.Port)"
    Write-Host "用户名: $($global:connectionParams.User)"
    Write-Host "`n请选择操作:"
    Write-Host "1. 备份数据库"
    Write-Host "2. 恢复数据库"
    Write-Host "3. 修改连接设置"
    Write-Host "4. 退出程序"
    Write-Host "========================================" -ForegroundColor Cyan
     
    $choice = Read-Host "`n请输入数字选择 (1-4)"
     
    switch ($choice) {
        "1" { Backup-Database; Pause; Show-MainMenu }
        "2" { Restore-Database; Pause; Show-MainMenu }
        "3" { Set-ConnectionConfig; Show-MainMenu }
        "4" { Exit }
        default { Show-MainMenu }
    }
}
 
# 配置连接信息（增加端口设置）
function Set-ConnectionConfig {
    Clear-Host
    Write-Host "`n当前连接设置:" -ForegroundColor Cyan
    Write-Host "1. 服务器地址: $($global:connectionParams.Host)"
    Write-Host "2. 端口号: $($global:connectionParams.Port)"
    Write-Host "3. 用户名: $($global:connectionParams.User)"
    Write-Host "4. 密码: $($global:connectionParams.Password)"
    Write-Host "5. 测试连接"
    Write-Host "6. 返回主菜单"
     
    $choice = Read-Host "`n请输入数字选择 (1-6)"
     
    switch ($choice) {
        "1" { 
            $hostName = Read-Host "输入服务器地址 (默认: localhost)"
            if ($hostName) { 
                $global:connectionParams.Host = $hostName 
                Write-Host "已设置为: $hostName" -ForegroundColor Green
            } else {
                $global:connectionParams.Host = "localhost"
            }
            Pause
            Set-ConnectionConfig
        }
        "2" { 
            $portInput = Read-Host "输入端口号 (默认: 3306)"
            if ($portInput) {
                try {
                    $port = [int]$portInput
                    if ($port -lt 1 -or $port -gt 65535) {
                        throw "端口号无效"
                    }
                    $global:connectionParams.Port = $port
                    Write-Host "已设置为: $port" -ForegroundColor Green
                } catch {
                    Write-Host "端口号必须是1-65535之间的整数!" -ForegroundColor Red
                }
            } else {
                $global:connectionParams.Port = 3306
            }
            Pause
            Set-ConnectionConfig
        }
        "3" { 
            $userName = Read-Host "输入用户名 (默认: root)"
            if ($userName) { 
                $global:connectionParams.User = $userName 
                Write-Host "已设置为: $userName" -ForegroundColor Green
            } else {
                $global:connectionParams.User = "root"
            }
            Pause
            Set-ConnectionConfig
        }
        "4" { 
            $password = Read-Host "输入密码 (默认: 123456)"
            if ($password) { 
                $global:connectionParams.Password = $password 
                Write-Host "密码已更新" -ForegroundColor Green
            } else {
                $global:connectionParams.Password = "123456"
            }
            Pause
            Set-ConnectionConfig
        }
        "5" {
            if (Test-MySqlConnection -hostName $global:connectionParams.Host `
                                    -port $global:connectionParams.Port `
                                    -userName $global:connectionParams.User `
                                    -password $global:connectionParams.Password) {
                Write-Host "`n连接成功! √" -ForegroundColor Green
                Write-Host "服务器: $($global:connectionParams.Host):$($global:connectionParams.Port)" -ForegroundColor Cyan
            } else {
                Write-Host "`n连接失败 ×" -ForegroundColor Red
                Write-Host "请检查服务器地址、端口号、用户名和密码" -ForegroundColor Yellow
            }
            Pause
            Set-ConnectionConfig
        }
        "6" { return }
        default { Set-ConnectionConfig }
    }
}
 
# 初始化
function Initialize-Tool {
    # 查找MySQL工具
    if (-not (Find-MySqlTools)) {
        Write-Host "`n错误: 未找到MySQL程序!" -ForegroundColor Red
        Write-Host "请确保电脑已安装MySQL或MariaDB" -ForegroundColor Yellow
        Write-Host "或者将本工具放在MySQL的bin目录下运行" -ForegroundColor Yellow
        Pause
        Exit
    }
     
    Write-Host "`n已找到MySQL工具:" -ForegroundColor Green
    Write-Host "mysql.exe    : $global:mysqlExe" -ForegroundColor Cyan
    Write-Host "mysqldump.exe: $global:mysqldumpExe" -ForegroundColor Cyan
     
    # 测试默认连接
    if (Test-MySqlConnection -hostName $global:connectionParams.Host `
                            -port $global:connectionParams.Port `
                            -userName $global:connectionParams.User `
                            -password $global:connectionParams.Password) {
        Write-Host "`n连接数据库成功! √" -ForegroundColor Green
        Write-Host "连接地址: $($global:connectionParams.Host):$($global:connectionParams.Port)" -ForegroundColor Cyan
        Start-Sleep -Seconds 1
        Show-MainMenu
    } else {
        Write-Host "`n默认连接失败 ×" -ForegroundColor Red
        Write-Host "请设置数据库连接信息" -ForegroundColor Yellow
        Set-ConnectionConfig
        Show-MainMenu
    }
}
 
# 启动工具
Initialize-Tool