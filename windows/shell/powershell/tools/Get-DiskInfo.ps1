# 获取磁盘信息
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
Select-Object DeviceID,
    @{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.FreeSpace / 1GB)}},
    @{Name="TotalSize(GB)";Expression={"{0:N2}" -f ($_.Size / 1GB)}}

# 打印到控制台
$disks | Format-Table -AutoSize

# 保存到文件
# $disks | Out-File -Encoding UTF8 "diskinfo.txt"
pause