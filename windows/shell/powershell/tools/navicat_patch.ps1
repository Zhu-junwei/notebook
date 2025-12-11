function Find-Navicat {
	$results = New-Object System.Collections.Generic.HashSet[string]

	# 方法 1：注册表寻找
	$regKeys = @(
		"HKLM:\SOFTWARE\PremiumSoft",
		"HKLM:\SOFTWARE\WOW6432Node\PremiumSoft",
		"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
		"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
	)
	foreach ($k in $regKeys) {
		if (Test-Path $k) {
			Get-ChildItem $k -ErrorAction SilentlyContinue | ForEach-Object {
				$p = Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue
				if ($p.DisplayName -like "*Navicat Premium*") {
					if ($p.InstallLocation -and (Test-Path (Join-Path $p.InstallLocation "navicat.exe"))) {
						$results.Add($p.InstallLocation.TrimEnd('\','/')) | Out-Null
					}
				}
			}
		}
	}

	# 方法 2：快捷方式寻找
	$lnkPaths = @("$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
					"$env:AppData\Microsoft\Windows\Start Menu\Programs")
	foreach ($lp in $lnkPaths) {
		if (Test-Path $lp) {
			Get-ChildItem $lp -Recurse -Filter "*navicat*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
				$ws = New-Object -ComObject WScript.Shell
				$path = $ws.CreateShortcut($_.FullName).TargetPath
				if ($path -and (Test-Path (Join-Path $path "navicat.exe"))) {
					$results.Add($path.TrimEnd('\','/')) | Out-Null
				}
			}
		}
	}

	# 方法 3：Program Files寻找
	$pfDirs = @("C:\Program Files", "C:\Program Files (x86)")
	foreach ($dir in $pfDirs) {
	   if (Test-Path $dir) {
		   $found = Get-ChildItem $dir -Recurse -Filter "navicat.exe" -ErrorAction SilentlyContinue
		   foreach ($f in $found) {
			   $path = $f.Directory.FullName
			   if ($path -and (Test-Path (Join-Path $path "navicat.exe"))) {
				   $results.Add($path.TrimEnd('\','/')) | Out-Null
			   }
		   }
	   }
   }
	return $results
}

function Get-ExeInfo($exePath) {
    # 打开文件读取架构
    $fs = [System.IO.File]::OpenRead($exePath)
    $br = New-Object System.IO.BinaryReader($fs)
    try {
        # 读取 PE Header 位置
        $fs.Seek(0x3C, 'Begin') | Out-Null
        $peOffset = $br.ReadInt32()

        # 读取 Machine 字段
        $fs.Seek($peOffset + 4, 'Begin') | Out-Null
        $machine = $br.ReadUInt16()

        $arch = switch ($machine) {
            0x014c { "x86" }
            0x8664 { "x64" }
            default { "未知架构" }
        }
        $ver = (Get-Item $exePath).VersionInfo.FileVersion
        return [PSCustomObject]@{
            Arch    = $arch
            Version = $ver
        }
    }
    finally {
        $br.Close()
        $fs.Close()
    }
}

Write-Host "
==================================================
              Navicat Premium 激活脚本
==================================================
" -ForegroundColor Cyan
# 执行查找
Write-Host "`n查找Navicat安装位置..." -ForegroundColor Cyan
$paths = Find-Navicat

if ($paths.Count -eq 1) {
	$path = @($paths)[0]
	Write-Host "找到 Navicat 安装路径" -ForegroundColor Green

	# 1. 获取 CPU 架构
	$NavicatInfo = Get-ExeInfo (Join-Path $path "navicat.exe")
	$arch = $NavicatInfo.Arch
	$version = $NavicatInfo.Version
	Write-Host "  位置： $path"
	Write-Host "  架构： $arch"
	Write-Host "  版本： $version"

   # 下载 ZIP 到临时目录
	$zip = "$env:TEMP\${arch}_patch.zip"
	Write-Host "`n下载激活补丁..." -ForegroundColor Cyan
	$url = "https://cdn.jsdelivr.net/gh/Zhu-junwei/software/navicat/${arch}_patch.zip"
	Write-Host "下载 → $url"
	try {
		Invoke-WebRequest -Uri $url -OutFile $zip -ErrorAction Stop
		Write-Host "下载成功！" -ForegroundColor Green
	} catch {
		Write-Host "下载失败：$url" -ForegroundColor Red
		Write-Host "请检查网络连接或URL是否正确。" -ForegroundColor Yellow
		$null = Read-Host
		exit
	}
	
	# 解压
	Write-Host "`n解压激活补丁..." -ForegroundColor Cyan
	Add-Type -AssemblyName System.IO.Compression.FileSystem
	$zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zip)
	Write-Host "`解压补丁文件: $(Split-Path $zip -Leaf) → $path"
	$zipArchive.Entries.FullName | ForEach-Object { Write-Host " - $_" }
	$zipArchive.Dispose()
	try {
		Expand-Archive -Force -LiteralPath $zip -DestinationPath $path
		Write-Host "解压完成！" -ForegroundColor Green
	} catch {
		Write-Host "解压失败" -ForegroundColor Red
	}
	Remove-Item $zip -Force -ErrorAction Stop
	Write-Host "`nNavicat Premium 激活完成，请重启应用使用" -ForegroundColor Green
} elseif ($paths.Count -gt 1) {
	Write-Host "`n检测到多个 Navicat 安装路径：" -ForegroundColor Yellow
	foreach ($p in $paths) {
		Write-Host " - $p" -ForegroundColor Cyan
	}
	Write-Host "`n请手动删除多余的 Navicat 文件夹，仅保留一个。" -ForegroundColor Red
	Write-Host "脚本已停止执行。" -ForegroundColor Red
} else {
	Write-Host "未找到 Navicat 安装路径。" -ForegroundColor Yellow
}

$null = Read-Host
