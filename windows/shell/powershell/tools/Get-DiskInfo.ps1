# 获取磁盘信息并保存为 diskinfo.txt
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | 
Select-Object DeviceID,
@{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.FreeSpace / 1GB)}},
@{Name="TotalSize(GB)";Expression={"{0:N2}" -f ($_.Size / 1GB)}} |
Out-File -Encoding UTF8 "diskinfo.txt"

# 打开 txt 文件
Start-Process "diskinfo.txt"
