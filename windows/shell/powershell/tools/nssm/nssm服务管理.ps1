# ===========================
# NSSM 服务管理菜单
# ===========================
$Global:ScriptName = "NSSM 服务管理脚本"
$Global:ScriptUser = "zjw"
$Global:ScriptVersion = "1.0.0"
$Global:ScriptUpdate = "20251215"
$Global:NssmInstallDir = "$env:ProgramFiles\NSSM"
$Global:NssmZipUrl    = "https://nssm.cc/ci/nssm-2.24-103-gdee49fc.zip"

$Global:ExitKeys = @("0", "q", "exit")

# 检测管理员权限，如果不是管理员则以管理员重新运行
function Ensure-RunAsAdmin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "正在以管理员权限重新启动脚本..." -ForegroundColor Yellow
        $scriptPathEscaped = $PSCommandPath -replace '(["`])', '``$1'
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPathEscaped`"" -Verb RunAs
        Exit
    }
}
Ensure-RunAsAdmin

# ---------------------------
# 读取菜单输入
# ---------------------------
function Read-MenuChoice {
    param([string]$Prompt = "请选择操作")
    (Read-Host $Prompt).Trim().ToLower()
}

# ---------------------------
# 下载并安装 NSSM
# ---------------------------
function Install-Nssm {
    $tempZip = Join-Path $env:TEMP "nssm.zip"
    $tempExtractDir = Join-Path $env:TEMP "nssm_extract"

    try {
        # 下载 ZIP
        Write-Host "`n正在下载 NSSM..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Global:NssmZipUrl -OutFile $tempZip -UseBasicParsing
        Write-Host "下载完成，正在解压..." -ForegroundColor Yellow

        # 创建安装目录
        if (-not (Test-Path $Global:NssmInstallDir)) {
            New-Item -Path $Global:NssmInstallDir -ItemType Directory | Out-Null
        }

        # 清理临时解压目录
        if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
        New-Item -Path $tempExtractDir -ItemType Directory | Out-Null

        # 解压 ZIP
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $tempExtractDir)

        # 找到所有 nssm.exe
        $nssmExes = Get-ChildItem -Path $tempExtractDir -Recurse -Filter "nssm.exe"
        if (-not $nssmExes -or $nssmExes.Count -eq 0) { throw "未找到 nssm.exe" }

        # 判断系统位数
        $is64 = [Environment]::Is64BitOperatingSystem
        $targetArch = if ($is64) { "win64" } else { "win32" }

        # 选择正确架构的 nssm.exe
        $sourceExe = $nssmExes | Where-Object { $_.Directory.Name -ieq $targetArch } | Select-Object -First 1
        if (-not $sourceExe) { throw "未找到 $targetArch\nssm.exe" }

        # 移动到安装目录根目录
        $destExe = Join-Path $Global:NssmInstallDir "nssm.exe"
        Move-Item -Path $sourceExe.FullName -Destination $destExe -Force
        Write-Host "NSSM 安装完成: $destExe" -ForegroundColor Green
		Write-Host
        $choice = Read-Host "是否将 NSSM 添加到系统 PATH? (y/N)"
        if ($choice -match '^[Yy]$') {
            $machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
			$newPath = "$machinePath;$Global:NssmInstallDir"
			[Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
			Write-Host "已成功添加到系统 PATH" -ForegroundColor Green
        }
		Start-Sleep 1
        return $destExe
    } catch {
        Write-Host "下载或安装 NSSM 失败: $_" -ForegroundColor Red
        Read-Host "`n按回车退出程序"
        Exit
    } finally {
        # 清理临时文件和目录
        if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
        if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force }
    }
}

function Initialize-Nssm {
    # 临时加入当前 PowerShell 会话 PATH
    if ($env:PATH -notmatch [Regex]::Escape($Global:NssmInstallDir)) {
        $env:PATH = "$Global:NssmInstallDir;$env:PATH"
    }
	$env:PATH = "$PSScriptRoot;$env:PATH"

    # 尝试获取 nssm.exe 路径
    $nssmPath = (Get-Command nssm.exe -ErrorAction SilentlyContinue).Source

    # 如果找不到，提示下载
    if (-not $nssmPath) {
        Write-Host "未找到 NSSM (nssm.exe)。" -ForegroundColor Red
        $choice = Read-Host "是否下载并安装 NSSM ? (y/N)"
        if ($choice -match "^[Yy]$") {
            $nssmPath = Install-Nssm
        } else {
            Write-Host "`n未安装 NSSM，程序无法继续。" -ForegroundColor Red
            Read-Host "`n按回车退出程序"
            Exit
        }
    }

    # 获取版本信息
    $fullVersion = & $nssmPath version
    $Global:NssmInfo = [PSCustomObject]@{
        Path    = $nssmPath
        Version = $fullVersion
    }
}
Initialize-Nssm

# ---------------------------
# 缩进输出函数
# ---------------------------
function Write-Indented {
    param(
        [string]$Text,
        [int]$Indent = 4,
        [ConsoleColor]$Color = "White"
    )
    $spaces = " " * $Indent
    Write-Host "$spaces$Text" -ForegroundColor $Color
}

# ---------------------------
# 获取所有 NSSM 服务及参数
# ---------------------------
function Get-NssmServices {
    $services = Get-CimInstance Win32_Service | Where-Object { $_.PathName -match "nssm.exe" }
    $serviceObjects = @()
    foreach ($svc in $services) {
        $paramsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)\Parameters"
        $params = if (Test-Path $paramsPath) { Get-ItemProperty $paramsPath } else { @{} }
        $serviceObjects += [PSCustomObject]@{
            Name          = $svc.Name
            DisplayName   = $svc.DisplayName
            Description   = $svc.Description
            State         = $svc.State
            StartMode     = $svc.StartMode
            NSSM_Path     = $svc.PathName
            AppExecutable = $params.Application
            AppParameters = $params.AppParameters
            AppDirectory  = $params.AppDirectory
        }
    }
    return $serviceObjects
}

# ---------------------------
# 显示服务列表菜单
# ---------------------------
function Show-ServiceListMenu {
    while ($true) {
        $services = Get-NssmServices
        Clear-Host
        Write-Host "=== NSSM 服务列表 ===`n"
		
		$indent = 4
		if (-not $services -or $services.Count -eq 0) {
			Write-Host (" " * $indent + "当前没有 NSSM 管理的服务。") -ForegroundColor Yellow
        } else {
			# 计算名称列对齐长度（包括序号和点的长度）
			$maxNameLength = ($services | ForEach-Object { $_.DisplayName.Length } | Measure-Object -Maximum).Maximum

			$i = 1
			foreach ($svc in $services) {
				# 序号 + 名称
				$nameText = (" " * $indent) + ("{0}. {1}" -f $i, $svc.DisplayName.PadRight($maxNameLength))
				# 状态前加 2 个空格保证间距
				$statusText = "  " + $svc.State
				# 输出名字白色，状态高亮
				Write-Host -NoNewline $nameText
				Write-Host $statusText -ForegroundColor (Get-StateColor $svc.State)
				$i++
			}
		}
		Write-Host
		Write-Host (" " * $indent + "0. 返回主菜单")
        $selection = Read-MenuChoice
        if ($Global:ExitKeys -contains $selection)  { return }
        if ($selection -match "^\d+$" -and $selection -le $services.Count -and $selection -ge 1) {
            $svc = $services[$selection - 1]
            Show-ServiceManagementMenu $svc
        } else {
            continue
        }
    }
}

function Get-StateColor {
    param(
        [string]$State
    )
    switch ($State) {
        "Running" { return "Green" }
        "Stopped" { return "Red" }
        default   { return "Yellow" }
    }
}


# ---------------------------
# 服务管理菜单
# ---------------------------
function Show-ServiceManagementMenu {
    param($svc)
    while ($true) {
        # 刷新服务状态
        $svc = Get-NssmServices | Where-Object { $_.Name -eq $svc.Name }
        Clear-Host
        Write-Host "=== 管理服务: $($svc.DisplayName) ==="
        Write-Host ("当前状态: " + $svc.State) -ForegroundColor (Get-StateColor $svc.State)

        Write-Host
        Write-Indented "1. 启动服务"
        Write-Indented "2. 停止服务"
        Write-Indented "3. 重启服务"
        Write-Indented "4. 查看详细参数"
        Write-Indented "5. 更改启动类型"
		Write-Indented "6. 编辑服务"
        Write-Indented "7. 删除服务`n"
        Write-Indented "0. 返回服务列表`n"
        $choice = Read-MenuChoice

        switch ($choice) {
            "1" {
                Write-Host "`n正在启动服务..." -ForegroundColor Yellow
                Start-Service $svc.Name
                Write-Host "服务已启动" -ForegroundColor Green
                Start-Sleep 1
            }
            "2" {
                Write-Host "`n正在停止服务..." -ForegroundColor Yellow
                Stop-Service $svc.Name -Force
                Write-Host "服务已停止" -ForegroundColor Green
                Start-Sleep 1
            }
            "3" {
                Write-Host "`n正在重启服务..." -ForegroundColor Yellow
                Restart-Service $svc.Name -Force
                Write-Host "服务已重启" -ForegroundColor Green
                Start-Sleep 1
            }
            "4" { Show-ServiceDetails $svc; Read-Host "`n按回车返回" }
            "5" {
                Write-Host "`n正在更改启动类型..." -ForegroundColor Yellow
                Change-ServiceStartMode $svc
                Write-Host "启动类型已更新" -ForegroundColor Green
                Start-Sleep 1
            }
			"6" {
				Write-Host "`n正在停止服务..." -ForegroundColor Yellow
				Stop-Service $svc.Name -Force
                Write-Host "`n正在打开服务编辑界面..." -ForegroundColor Yellow
                Start-Process "nssm.exe" -ArgumentList "edit $($svc.Name)" -Wait
                Start-Sleep 1
            }
            "7" { Remove-ServiceWithConfirmation $svc.Name; return }
            { $Global:ExitKeys -contains $_ } { return }
            default {
                continue
            }
        }
    }
}


# ---------------------------
# 显示详细参数
# ---------------------------
function Show-ServiceDetails {
    param($svc)
    Write-Host "`n=== 服务详细参数 ===" -ForegroundColor Cyan
    Write-Indented "Name         : $($svc.Name)" 4
    Write-Indented "DisplayName  : $($svc.DisplayName)" 4
    Write-Indented "Description  : $($svc.Description)" 4
    Write-Indented "State        : $($svc.State)" 4
    Write-Indented "StartMode    : $($svc.StartMode)" 4
    Write-Indented "NSSM_Path    : $($svc.NSSM_Path)" 4
    Write-Indented "Application  : $($svc.AppExecutable)" 4
    Write-Indented "Parameters   : $($svc.AppParameters)" 4
    Write-Indented "Directory    : $($svc.AppDirectory)`n" 4
}

# ---------------------------
# 更改启动类型
# ---------------------------
function Change-ServiceStartMode {
    param($svc)
    Write-Host "`n当前启动类型: $($svc.StartMode)"
    Write-Indented "1. Automatic"
    Write-Indented "2. Manual"
    Write-Indented "3. Disabled"
    $choice = Read-Host "`n选择新的启动类型"
    $mode = switch ($choice) {
        "1" { "Automatic" }
        "2" { "Manual" }
        "3" { "Disabled" }
        default { Write-Host "`n无效选择"; return }
    }
    Set-Service $svc.Name -StartupType $mode
    Write-Host "`n启动类型已更新为 $mode" -ForegroundColor Green
}

# ---------------------------
# 删除服务确认
# ---------------------------
function Remove-ServiceWithConfirmation {
    param($svcName)

    Write-Host
    $confirm1 = Read-Host "确认删除服务 $svcName ? (y/N)"
    if ($confirm1 -notmatch "^[Yy]$") {
        Write-Host "`n取消删除" -ForegroundColor Yellow
        Start-Sleep 1
        return
    }
    $confirm2 = Read-Host "!!! 警告 !!! 此操作不可撤销，真的要删除 $svcName ? (y/N)"
    if ($confirm2 -notmatch "^[Yy]$") {
        Write-Host "`n取消删除" -ForegroundColor Yellow
        Start-Sleep 1
        return
    }
    Write-Host "`n正在删除服务..." -ForegroundColor Yellow
    # 检查服务是否存在
    $service = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Host "服务 $svcName 不存在" -ForegroundColor Red
        Start-Sleep 2
        return
    }
    # 如果服务在运行，先停止它
    if ($service.Status -eq 'Running') {
        Write-Host "服务正在运行，正在停止服务..." -ForegroundColor Yellow
        Stop-Service -Name $svcName -Force -ErrorAction SilentlyContinue
        $service.WaitForStatus('Stopped', '00:00:10')  # 最多等待10秒
    }
    # 使用 nssm 删除服务
    & nssm.exe remove $svcName confirm
    Write-Host "服务已删除" -ForegroundColor Green
    Start-Sleep 3
}



# ---------------------------
# 添加 NSSM 服务 GUI
# ---------------------------
function Add-NssmService {
    Clear-Host
    Write-Host "=== 添加 NSSM 服务 ===`n"
    Start-Process nssm.exe -ArgumentList "install"
}

# ---------------------------
# 关于 / 帮助
# ---------------------------
function Show-AboutMenu {
    Clear-Host

    Write-Host @"
=== NSSM 服务管理脚本 ===

	【脚本信息】
	 脚本版本    : $ScriptName $ScriptVersion ($ScriptUpdate)
	 作者        : $scriptUser
	 NSSM 版本   : $($Global:NssmInfo.Version)
	 NSSM 位置   : $($Global:NssmInfo.Path)
	 NSSM 官网   ： https://nssm.cc

	【脚本功能】
	 管理所有由 NSSM 托管的 Windows 服务
	 提供服务查看、启动、停止、重启、编辑、删除等操作
	 自动检测并安装 NSSM，无需手动配置
	 适合将普通程序（EXE / BAT / JAR / Python 等）注册为系统服务

	【主要能力】
	 查看 NSSM 服务列表及运行状态
	 控制服务生命周期（Start / Stop / Restart）
	 查看服务详细参数（程序、参数、工作目录）
	 修改服务启动类型（Automatic / Manual / Disabled）
	 调用 NSSM 官方 GUI 编辑服务
	 安全删除服务（双重确认）

	【什么是 NSSM】
	 NSSM（Non-Sucking Service Manager）用于将普通程序
	 封装为标准 Windows Service，比 sc.exe 更稳定、易用。

	【典型使用场景】
	 Java / Spring Boot / JAR 后台服务
	 Node.js / Python / Go 常驻程序
	 自定义脚本随系统启动运行

	【注意事项】
	 本脚本需以管理员权限运行
	 删除服务操作不可恢复，请谨慎
	 编辑服务前请确认程序路径与参数正确
"@ -ForegroundColor Cyan

    Read-Host "`n按回车返回主菜单"
}

# ---------------------------
# 主菜单
# ---------------------------
function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host "=== NSSM 服务管理菜单 ===`n"
        Write-Indented "1. 服务列表" -Color "Cyan"
        Write-Indented "2. 添加新服务"
		Write-Indented "3. 关于`n"
        Write-Indented "0. 退出"
        Write-Host
        $choice = Read-MenuChoice
        switch ($choice) {
            "1" { Show-ServiceListMenu }
            "2" { Add-NssmService }
            "3" { Show-AboutMenu }
            { $Global:ExitKeys -contains $_ } { Exit }
        }
    }
}

# ===========================
# 启动主菜单
# ===========================
Show-MainMenu
