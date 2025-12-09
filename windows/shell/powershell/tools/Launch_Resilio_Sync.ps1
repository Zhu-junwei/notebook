function Start-Resilio-Sync {
	$checkDir = "H:\sync"
	$exe = "$env:APPDATA\Resilio Sync\Resilio Sync.exe"

	if ((Test-Path $checkDir) -and
		(Test-Path $exe) -and
		(-not (Get-Process -Name "Resilio Sync" -ErrorAction SilentlyContinue))) {
		Start-Process -FilePath $exe -WindowStyle Hidden
		Write-Output "已启动 Resilio Sync"
	}
}

Start-Resilio-Sync