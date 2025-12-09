function Show-Message{
	param ($message)
	Write-Output "$message"
}

function Get-Hello {
    param([string]$Name = 'World')
    "Hello, $Name!"
}