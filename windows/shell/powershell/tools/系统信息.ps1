# Get system information
$os = Get-WmiObject -Class Win32_OperatingSystem
$computer = Get-WmiObject -Class Win32_ComputerSystem

# Display system information
Write-Host "Operating System: $($os.Caption)"
Write-Host "OS Version: $($os.Version)"
Write-Host "Computer Name: $($computer.Name)"
Write-Host "Total Physical Memory: $([math]::round($computer.TotalPhysicalMemory / 1GB, 2)) GB"
Write-Host "Free Physical Memory: $([math]::round($os.FreePhysicalMemory / 1MB, 2)) GB"  # 修正单位问题
Write-Host "User Name: $($os.RegisteredUser)"

# Wait for user input to exit
Pause