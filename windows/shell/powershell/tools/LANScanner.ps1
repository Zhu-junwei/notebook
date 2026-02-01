Write-Host "==========================================" -ForegroundColor Green
Write-Host "         局域网设备扫描器         " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# -----------------------------
# 在线检测函数（核心）
# -----------------------------
function Test-DeviceOnline {
    param([string]$IP)
    $arp = Get-NetNeighbor -IPAddress $IP -ErrorAction SilentlyContinue
    if (-not $arp) {
        return @{ Online = $false; Reason = "无ARP" }
    }
    if ($arp.State -in 'Reachable','Stale','Delay','Probe') {
        if (Test-Connection $IP -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            return @{ Online = $true; Reason = "Ping" }
        }
        return @{ Online = $true; Reason = "ARP在线" }
    }
    return @{ Online = $false; Reason = "缓存失效" }
}

# -----------------------------
# 1. 获取 IPv4 网卡
# -----------------------------
$adapters = Get-NetIPAddress -AddressFamily IPv4 |
Where-Object {
    $_.IPAddress -notmatch '^127\.|^169\.254\.' -and
    $_.PrefixLength -eq 24
}

if (-not $adapters) {
    Write-Host "未发现可用 IPv4 网卡" -ForegroundColor Red
    Read-Host
    exit
}

# -----------------------------
# 2. 生成网段
# -----------------------------
$networks = $adapters.IPAddress |
ForEach-Object {
    if ($_ -match '^(\d+\.\d+\.\d+)\.\d+$') {
        "$($Matches[1]).0/24"
    }
} | Select-Object -Unique

# -----------------------------
# 3. 选择网段
# -----------------------------
if ($networks.Count -eq 1) {
    $network = $networks[0]
    Write-Host "`n仅检测到一个网段，自动使用：$network" -ForegroundColor Yellow
}
else {
    do {
        Write-Host "`n检测到多个网段，请选择要扫描的网段：" -ForegroundColor Cyan
        for ($i = 0; $i -lt $networks.Count; $i++) {
            Write-Host "[$($i + 1)] $($networks[$i])"
        }

        $choice = Read-Host "请输入编号 (1-$($networks.Count))"
        $valid  = [int]::TryParse($choice, [ref]$null) -and
                  $choice -ge 1 -and
                  $choice -le $networks.Count

        if (-not $valid) {
            Write-Host "输入无效，请重新选择。" -ForegroundColor Red
        }
    } until ($valid)

    $network = $networks[$choice - 1]
}

$prefix = $network -replace '\.0/24',''

# -----------------------------
# 4. 快速建立 ARP 表
# -----------------------------
Write-Host "`n[1/2] 正在向网段 $network 发送探测包 (Ping)..." -ForegroundColor Cyan
foreach ($i in 1..254) {
    $p = New-Object System.Net.NetworkInformation.Ping
    [void]$p.SendPingAsync("$prefix.$i", 800)
}
Start-Sleep -Seconds 1

# -----------------------------
# 5. 获取本机 IP → MAC
# -----------------------------
$localMapping = @{}
Get-NetIPAddress -AddressFamily IPv4 |
Where-Object { $_.IPAddress -notmatch '^127\.|^169\.254\.' } |
ForEach-Object {
    $adapter = Get-NetAdapter -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    if ($adapter) {
        $localMapping[$_.IPAddress] = $adapter.MacAddress.Replace("-", ":").ToUpper()
    }
}

# -----------------------------
# 6. 解析 ARP 表
# -----------------------------
$arpRegex = '(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(?<MAC>([0-9a-f]{2}[:-]){5}[0-9a-f]{2})'
$globalArp = arp -a

$potentialIPs = @()
foreach ($line in $globalArp) {
    if ($line -match $arpRegex) {
        $ip  = $Matches.IP
        $mac = $Matches.MAC.ToUpper().Replace("-", ":")

        if ($ip.StartsWith("$prefix.") -and
            -not $localMapping.ContainsKey($ip) -and
            $ip -notmatch '\.255$') {

            $potentialIPs += [PSCustomObject]@{
                IP  = $ip
                MAC = $mac
            }
        }
    }
}

# -----------------------------
# 7. 构建结果
# -----------------------------
$finalList = @()

# 本机
foreach ($ip in $localMapping.Keys) {
    if ($ip.StartsWith("$prefix.")) {
        $finalList += [PSCustomObject]@{
            IP       = "$ip*"
            MAC      = $localMapping[$ip]
            IsOnline = $true
            Reason   = "本机"
            RawIP    = $ip
        }
    }
}

Write-Host "[2/2] 正在判断设备在线状态..." -ForegroundColor Cyan

foreach ($dev in $potentialIPs | Select-Object -Unique IP, MAC) {
    $result = Test-DeviceOnline $dev.IP
    $finalList += [PSCustomObject]@{
        IP       = $dev.IP
        MAC      = $dev.MAC
        IsOnline = $result.Online
        Reason   = $result.Reason
        RawIP    = $dev.IP
    }
}

# -----------------------------
# 8. 输出
# -----------------------------
Write-Host "`n============== 扫描结果 ==============" -ForegroundColor Cyan

$sorted = $finalList | Sort-Object {[version]$_.RawIP}

foreach ($item in $sorted) {
    $status = if ($item.IsOnline) {
		switch ($item.Reason) {
			"Ping"     { "在线" }
			"ARP在线"  { "在线（未响应 Ping）" }
			"本机"     { "本机" }
			default    { "在线" }
		}
	} else {
		switch ($item.Reason) {
			"缓存失效" { "离线（缓存失效）" }
			default    { "离线" }
		}
	}


    $line = "{0,-20} {1,-22} {2}" -f $item.IP, $item.MAC, $status

    if ($item.IsOnline) {
        Write-Host $line -ForegroundColor Green
    } else {
        Write-Host $line -ForegroundColor DarkGray
    }
}

$online = ($finalList | Where-Object { $_.IsOnline }).Count
$total  = $finalList.Count

Write-Host "`n扫描完成：$online / $total 台设备在线" -ForegroundColor Green
Write-Host "`n按任意键退出..."
$null = [System.Console]::ReadKey()
