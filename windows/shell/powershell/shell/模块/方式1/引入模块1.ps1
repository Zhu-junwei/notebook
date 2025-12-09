<# 
	引入模块，这里只有一个psm1文件，后缀可以省略
	
	PowerShell 会按顺序查找：
		MyModule.psd1
		MyModule.psm1
		MyModule.dll
#>
Import-Module ./MyModule

Show-Message "Hello World!"
Start-Sleep -Seconds 3