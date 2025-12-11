function Download-FileWithProgress {
    param(
        [Parameter(Mandatory = $true)] [string]$Url,
        [Parameter(Mandatory = $true)] [string]$OutFile,
        [int]$BufferSize = 64KB
    )

    Add-Type -AssemblyName System.Net.Http
    $client = New-Object System.Net.Http.HttpClient

    function Convert-Size {
        param($bytes)
        if ($null -eq $bytes) { return "未知" }
        if ($bytes -lt 1MB) { return ("{0:N2} KB" -f ($bytes/1KB)) }
        elseif ($bytes -lt 1GB) { return ("{0:N2} MB" -f ($bytes/1MB)) }
        else { return ("{0:N2} GB" -f ($bytes/1GB)) }
    }

    try {
        $response = $client.GetAsync($Url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        if (-not $response.IsSuccessStatusCode) {
            throw "下载失败: $($response.StatusCode)"
        }

        $total = $response.Content.Headers.ContentLength

        if (-not $total) {
            Write-Host "无法获取文件大小，使用一次性下载..." -ForegroundColor Yellow
            [System.IO.File]::WriteAllBytes($OutFile, $response.Content.ReadAsByteArrayAsync().Result)
            Write-Host "文件已下载到: $OutFile" -ForegroundColor Green
            return
        }

        $stream = $response.Content.ReadAsStreamAsync().Result
        $dir = [System.IO.Path]::GetDirectoryName($OutFile)
        if (-not [System.IO.Directory]::Exists($dir)) { [System.IO.Directory]::CreateDirectory($dir) | Out-Null }

        $file = [System.IO.File]::Open($OutFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)

        $buffer = New-Object byte[] $BufferSize
        $downloaded = 0

        while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $file.Write($buffer, 0, $read)
            $downloaded += $read

            $percent = if ($total -gt 0) { [math]::Round(($downloaded / $total) * 100, 2) } else { 0 }

            # 进度条计算
            $barLength = 40
            $filled = [math]::Floor($percent / (100 / $barLength))
            $bar = ('=' * $filled).PadRight($barLength)
            $recvStr = Convert-Size $downloaded
            $totalStr = Convert-Size $total
            try { $w = [console]::WindowWidth - 1 } catch { $w = 120 }

            $clear = ' ' * $w
            Write-Host "`r$clear`r[$bar] $percent% ($recvStr / $totalStr)" -NoNewline
        }
		Write-Host
    }
    catch {
        Write-Host "`n发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        if ($file) { $file.Close(); $file.Dispose() }
        if ($stream) { $stream.Close(); $stream.Dispose() }
        if ($client) { $client.Dispose() }
    }
}
Download-FileWithProgress -Url "https://files.cnblogs.com/files/zjw-blog/config.json" -OutFile "$env:TEMP\temp.json"
pause
