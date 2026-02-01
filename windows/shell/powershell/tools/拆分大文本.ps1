param (
    [string]$Path
)

# 路径输入
if (-not $Path) { $Path = Read-Host "请输入要拆分的文件路径" }
$Path = $Path.Trim('"').Trim()
if (-not (Test-Path $Path)) { Write-Error "文件不存在: $Path"; exit 1 }

# 每份大小输入
$value = Read-Host "请输入每个文件大小（MB，数字）"
if (-not ($value -as [int]) -or $value -le 0) { Write-Error "大小必须是正整数"; exit 1 }
$SizeMB = [int]$value
$maxBytes = $SizeMB * 1MB

# 输出目录
$ParentDir = Split-Path $Path -Parent
if (-not $ParentDir) { $ParentDir = Get-Location }
$OutDir = Join-Path $ParentDir "split_out"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
$ext      = [System.IO.Path]::GetExtension($Path)

Write-Host "源文件   : $Path"
Write-Host "每份大小 : $SizeMB MB"
Write-Host "输出目录 : $OutDir"
Write-Host "开始拆分..." -ForegroundColor Cyan

# 缓冲区设置
$bufferSize = 4MB
$fileIndex = 1
$bytesWritten = 0

$fsIn = [System.IO.File]::OpenRead($Path)
$outFile = Join-Path $OutDir ("{0}_part_{1:D3}{2}" -f $baseName, $fileIndex, $ext)
$fsOut = [System.IO.File]::OpenWrite($outFile)
$buffer = New-Object byte[] $bufferSize

while (($read = $fsIn.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $offset = 0
    $remaining = $read

    while ($remaining -gt 0) {
        $spaceLeft = $maxBytes - $bytesWritten
        $toWrite = [Math]::Min($remaining, $spaceLeft)

        # 写入当前文件
        $fsOut.Write($buffer, $offset, $toWrite)

        $bytesWritten += $toWrite
        $offset += $toWrite
        $remaining -= $toWrite

        # 如果当前文件已满，切换新文件
        if ($bytesWritten -ge $maxBytes) {
            $fsOut.Close()
            Write-Host "生成: $outFile"

            $fileIndex++
            $outFile = Join-Path $OutDir ("{0}_part_{1:D3}{2}" -f $baseName, $fileIndex, $ext)
            $fsOut = [System.IO.File]::OpenWrite($outFile)
            $bytesWritten = 0
        }
    }
}

$fsOut.Close()
$fsIn.Close()
Write-Host "生成: $outFile"
Write-Host "拆分完成，结果位于 split_out 目录" -ForegroundColor Green
