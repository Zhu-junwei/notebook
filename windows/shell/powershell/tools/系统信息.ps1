# Get system information
$os = Get-WmiObject -Class Win32_OperatingSystem
$computer = Get-WmiObject -Class Win32_ComputerSystem

# Display system information
Write-Host "Operating System: $($os.Caption)"
Write-Host "OS Version: $($os.Version)"
Write-Host "Computer Name: $($computer.Name)"
Write-Host "Total Physical Memory: $([math]::round($os.FreePhysicalMemory / 1MB, 2))GB / $([math]::round($computer.TotalPhysicalMemory / 1GB, 2))GB"
Write-Host ("Install Date: " + [Management.ManagementDateTimeConverter]::ToDateTime($os.InstallDate).ToString("yyyy-MM-dd HH:mm:ss"))
Write-Host ("Last Up Time: " + [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime).ToString("yyyy-MM-dd HH:mm:ss"))
# Wait for user input to exit
Pause