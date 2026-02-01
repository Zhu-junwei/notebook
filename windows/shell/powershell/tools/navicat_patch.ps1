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
				if ($p.DisplayName -like "*Navicat*") {
					if ($p.InstallLocation -and (Test-Path (Join-Path $p.InstallLocation "navicat.exe"))) {
						$results.Add($p.InstallLocation.TrimEnd('\','/')) | Out-Null
					}
				}
			}
		}
	}

	# 方法 2：快捷方式寻找
	$desktopPath = Join-Path -Path $env:USERPROFILE -ChildPath "Desktop"
	# 然后创建数组并将桌面路径添加进去
	$lnkPaths = @(
		"$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
		"$env:AppData\Microsoft\Windows\Start Menu\Programs",
		$desktopPath
	)
	foreach ($lp in $lnkPaths) {
		if (Test-Path $lp) {
			Get-ChildItem $lp -Recurse -Filter "*navicat*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
				$ws = New-Object -ComObject WScript.Shell
				$path = $ws.CreateShortcut($_.FullName).TargetPath
				if ($path -and (Test-Path $path)) {
					if ([System.IO.Path]::GetFileName($path) -ieq "navicat.exe") {
						$results.Add([System.IO.Path]::GetDirectoryName($path).TrimEnd('\','/')) | Out-Null
					}
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
        $exeVersionInfo = (Get-Item $exePath).VersionInfo
        return [PSCustomObject]@{
            arch    = $arch
            versionInfo = $exeVersionInfo
        }
    }
    finally {
        $br.Close()
        $fs.Close()
    }
}

function Download-Patch {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.HashSet[string]] $ArchSet
    )
	Write-Host "`n查找Navicat补丁..." -ForegroundColor Yellow

    # 默认下载 URL
    $patchMap = @{
        "x64" = @{
            downloadURL = "https://github.com/Zhu-junwei/software/raw/main/navicat/x64_patch.zip"
            localPatch   = Join-Path $env:TEMP "x64_patch.zip"
        }
        "x86" = @{
            downloadURL = "https://github.com/Zhu-junwei/software/raw/main/navicat/x86_patch.zip"
            localPatch   = Join-Path $env:TEMP "x86_patch.zip"
        }
    }

    # 判断脚本执行方式
    $isMemory = [string]::IsNullOrEmpty($PSCommandPath)

    foreach ($arch in $ArchSet) {
        if (-not $PatchMap.ContainsKey($arch)) {
            Write-Host "未找到架构 $arch 对应的补丁路径，跳过。" -ForegroundColor Red
            continue
        }

        $patchInfo = $PatchMap[$arch]

        # 如果是本地文件执行，检查脚本目录是否已有 patch
        if (-not $isMemory) {
            $localPatch = Join-Path (Split-Path -Parent $PSCommandPath) ("${arch}_patch.zip")
            if (Test-Path $localPatch) {
                $PatchMap[$arch].localPatch = $localPatch
                Write-Host "Navicat补丁${arch}_patch.zip已存在，将会进行离线激活。" -ForegroundColor Gray
            }
        }

        $url = $patchInfo.downloadURL
        $zip = $patchInfo.localPatch
	
        if (-not (Test-Path $zip)) {
			Write-Host "`正在联网下载补丁: $zip ← $url" -ForegroundColor Blue
            try {
                Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -ErrorAction Stop
                Write-Host "补丁下载成功。" -ForegroundColor Green
                Start-Sleep -Milliseconds 500
            }
            catch {
				# 打印详细的错误信息
				Write-Host "补丁下载失败：$url" -ForegroundColor Red
				Write-Host "错误信息：$($_.Exception.Message)" -ForegroundColor Red
				Write-Host "堆栈跟踪：$($_.Exception.StackTrace)" -ForegroundColor Red
				Exit-Script
			}
        }
    }
	return $patchMap
}

function Clean-Temp-Patch { 
	Get-ChildItem $env:TEMP -Filter "x*_patch.zip" -File -ErrorAction SilentlyContinue | Remove-Item -Force 
}

function Exit-Script {
	$null = Read-Host
	exit
}

Clean-Temp-Patch
$asciiArt = @"
    ___       ___       ___       ___       ___       ___       ___   
   /\__\     /\  \     /\__\     /\  \     /\  \     /\  \     /\  \  
  /:| _|_   /::\  \   /:/ _/_   _\:\  \   /::\  \   /::\  \    \:\  \ 
 /::|/\__\ /::\:\__\ |::L/\__\ /\/::\__\ /:/\:\__\ /::\:\__\   /::\__\
 \/|::/  / \/\::/  / |::::/  / \::/\/__/ \:\ \/__/ \/\::/  /  /:/\/__/
   |:/  /    /:/  /   L;;/__/   \:\__\    \:\__\     /:/  /   \/__/   
   \/__/     \/__/               \/__/     \/__/     \/__/            

              Navicat全家桶激活脚本v1.1 2026-01-07
"@
Write-Host $asciiArt -ForegroundColor Cyan
Start-Sleep -Seconds 3
# 执行查找
Write-Host "`n查找已安装Navicat位置..." -ForegroundColor Yellow
$paths = Find-Navicat

if($paths.Count -eq 0) {
	Write-Host "未找到 Navicat 安装路径。" -ForegroundColor DarkRed
	$null = Read-Host
	exit
} else {
	$archSet = New-Object System.Collections.Generic.HashSet[string]
	$navicatInfoes = @()
	foreach($path in $paths){
		# navicat安装信息
		$navicatInfo = Get-ExeInfo (Join-Path $path "navicat.exe")
		$arch = $navicatInfo.arch
		$archSet.Add($arch) | Out-Null
		Write-Host "`找到已安装Navicat信息：" -ForegroundColor Cyan
		Write-Host "  位置： $path"
		Write-Host "  架构： $($navicatInfo.arch)"
		Write-Host "  版本： $($navicatInfo.versionInfo.FileVersion)"
		Write-Host "  产品： $($navicatInfo.versionInfo.ProductName)"
		$navicatInfoes += [PSCustomObject]@{
			path = $path
			navicatInfo = $navicatInfo
		}
	}
	
	$patchMap = Download-Patch $archSet
	
	Write-Host "`n开始激活Navicat..." -ForegroundColor Yellow
	Add-Type -AssemblyName System.IO.Compression.FileSystem
	foreach ($nav in $navicatInfoes) {
		$navicatInfo = $nav.navicatInfo
		$arch = $navicatInfo.arch
		Write-Host "正在激活 $($navicatInfo.versionInfo.ProductName) $($arch) $($navicatInfo.versionInfo.FileVersion)" -ForegroundColor Cyan
		if ($PatchMap.ContainsKey($arch)) {
			$patchZip = $PatchMap[$arch].localPatch
			$destPath = $nav.path
			Write-Host "解压补丁文件: $(Split-Path $patchZip -Leaf) → $destPath"
			Expand-Archive -Path $patchZip -DestinationPath $destPath -Force
		}
		Write-Host "已激活 $($navicatInfo.versionInfo.ProductName) $($arch) $($navicatInfo.versionInfo.FileVersion)" -ForegroundColor Green
	}
	Clean-Temp-Patch
	Write-Host "`nNavicat 产品激活完成，请重启应用使用" -ForegroundColor Green
	Exit-Script
}

