# 生成二维码
function Generate-QRCode {
    param (
        [string]$Text,
        [string]$OutputPath = "qrcode.png"
    )

    # 生成二维码的 API URL
    $url = "https://api.qrserver.com/v1/create-qr-code/?data=$Text&size=200x200"

    # 下载二维码并保存到指定路径
    Invoke-WebRequest -Uri $url -OutFile $OutputPath

    Write-Host "QR Code saved to $OutputPath"
}

# 获取用户输入的文本
$text = Read-Host "Enter the text for the QR code"

# 获取用户输入的文件路径，如果为空则使用默认值
$outputPath = Read-Host "Enter the output file path (default: qrcode.png)"
if ([string]::IsNullOrEmpty($outputPath)) {
    $outputPath = "qrcode.png"  # 如果用户未输入路径，则使用默认值
}

# 调用函数生成二维码
Generate-QRCode -Text $text -OutputPath $outputPath

# 暂停终端，等待用户输入
Read-Host "Press Enter to exit"