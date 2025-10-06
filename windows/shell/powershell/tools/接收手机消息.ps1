# 启动本地 HTTP 服务，监听端口 8000，接收 JSON 消息并显示通知
$listener = New-Object System.Net.HttpListener
$port=8000
$listener.Prefixes.Add("http://+:$port/notify/")
# 配置图标目录
$iconDir = "D:\systemfile\Pictures\ico\"
try {
	$listener.Start()
	Write-Host "🟢 端口 $port 正在等待通知推送..."
} catch {
	Write-Host "❌ 无法启动监听器，端口 $port 可能已被占用。"
	Read-Host
	return
}

while ($true) {
	$context = $listener.GetContext()
	$request = $context.Request
	$reader = New-Object System.IO.StreamReader($request.InputStream)
	$body = $reader.ReadToEnd()
	$reader.Close()
	try {
		$data = $body | ConvertFrom-Json
		Write-Host "✅ 收到通知：$data"
		$title = $data.title
		$message = $data.message
		$when = $data.when
		$packageName = $data.packageName
		# 拼接图标路径
		$iconPath = Join-Path $iconDir "$packageName.png"
		if (-Not (Test-Path $iconPath)) {
			New-BurntToastNotification -Text "$title | $packageName", $message, "$when"
		} else {
			New-BurntToastNotification -AppLogo $iconPath -Text "$title", $message, "$when"
		}
	} catch {
		Write-Host "❌ JSON 解析失败：$body"
	}
	$response = $context.Response
	$response.StatusCode = 200
	$response.StatusDescription = "OK"
	$response.Close()
}
