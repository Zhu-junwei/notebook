<# 
	引入模块，这里只有一个psm1文件，后缀可以省略
	
	PowerShell 会按顺序查找：
		MyModule2.psd1
		MyModule2.psm1
		MyModule2.dll
#>
Import-Module ./MyModule2

Show-Message "Hello World!"
try {
	# 这里模块并没有导出这个方法，所以会报错
	Get-Hello "zjw"
} catch {
	 Write-Output "错误：$($_.Exception.Message)"
}


Start-Sleep -Seconds 3