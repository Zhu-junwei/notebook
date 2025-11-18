# ============================
#  配置：从authenticator.txt加载otpauth URL
# ============================
function Get-OtpAuthLinks {
	param (
		[string]$fileName = "authenticator.txt"  # 默认文件名
	)
	$links = @()
	$authenticatorPath = Join-Path (Get-Location) $fileName
	if (Test-Path $authenticatorPath) {
		$fileLinks = Get-Content $authenticatorPath | Where-Object { $_ -notmatch '^\s*(#|//|;)' -and $_.Trim() -ne '' }
		$links += $fileLinks
	}
	# 示例链接
	if ($links.Count -eq 0) {
		$links += "otpauth://totp/Example:user?secret=DMETBKDJAAY3D2K3&issuer=这是一个示例"
	}
	
	return $links
}

# ============================
#  函数：解析 otpauth URL
# ============================
function Parse-OtpAuthUrl {
	param([string]$url)

	# 先解码 URL，防止 URL 编码的问题
	$urlDecoded = [System.Uri]::UnescapeDataString($url).Trim()

	# 移除 "otpauth://totp/" 部分
	$clean = $urlDecoded -replace "^otpauth://totp/", ""

	# 按 "?" 分割 URL，分为账户部分和查询参数部分
	$parts = $clean -split "\?"
	$namePart = $parts[0]
	$queryPart = $parts[1]

	# 解析账户部分
	$account = $namePart
	$issuerFromName = ""
	if ($namePart -match "(.+?):(.+)") {
		$issuerFromName = $matches[1]
		$account = $matches[2]
	}

	# 解析查询参数部分
	$params = @{}
	foreach ($q in $queryPart -split "&") {
		$kv = $q -split "="
		$params[$kv[0]] = $kv[1]
	}

	# 获取 period 和 digits，若无则使用默认值
	$period = if ($params["period"]) { [int]$params["period"] } else { 30 }
	$digits = if ($params["digits"]) { [int]$params["digits"] } else { 6 }
	$issuer = if ($params["issuer"]) { $params["issuer"] } else { $issuerFromName }

	# 返回包含解析信息的对象
	return [PSCustomObject]@{
		Issuer    = $issuer
		Account   = $account
		Secret    = $params["secret"]
		Period    = $period
		Digits    = $digits
	}
}

function ConvertFrom-Base32 {
	param([string]$Base32String)
	
	$Base32String = $Base32String.ToUpper() -replace '[=]', '' -replace '[^A-Z2-7]', ''
	$base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
	$bytes = [System.Collections.Generic.List[byte]]::new()
	
	$buffer = 0
	$bitsLeft = 0
	
	foreach ($char in $Base32String.ToCharArray()) {
		$value = $base32Chars.IndexOf($char)
		if ($value -eq -1) { continue }
		
		$buffer = ($buffer -shl 5) -bor $value
		$bitsLeft += 5
		
		if ($bitsLeft -ge 8) {
			$bytes.Add([byte](($buffer -shr ($bitsLeft - 8)) -band 0xFF))
			$bitsLeft -= 8
		}
	}
	
	return $bytes.ToArray()
}

function Get-Otp($SECRET, $LENGTH, $WINDOW){
	$enc = [System.Text.Encoding]::UTF8
	$hmac = New-Object -TypeName System.Security.Cryptography.HMACSHA1
	$hmac.key = Convert-HexToByteArray(Convert-Base32ToHex(($SECRET.ToUpper())))
	$timeBytes = Get-TimeByteArray $WINDOW
	$randHash = $hmac.ComputeHash($timeBytes)
	
	$offset = $randhash[($randHash.Length-1)] -band 0xf
	$fullOTP = ($randhash[$offset] -band 0x7f) * [math]::pow(2, 24)
	$fullOTP += ($randHash[$offset + 1] -band 0xff) * [math]::pow(2, 16)
	$fullOTP += ($randHash[$offset + 2] -band 0xff) * [math]::pow(2, 8)
	$fullOTP += ($randHash[$offset + 3] -band 0xff)

	$modNumber = [math]::pow(10, $LENGTH)
	$otp = $fullOTP % $modNumber
	$otp = $otp.ToString("0" * $LENGTH)
	return $otp
}

function Get-TimeByteArray($WINDOW) {
	$span = [int]((Get-Date).ToUniversalTime() - [datetime]'1970-01-01').TotalSeconds
	$unixTime = [Convert]::ToInt64([Math]::Floor($span/$WINDOW))
	$byteArray = [BitConverter]::GetBytes($unixTime)
	[array]::Reverse($byteArray)
	return $byteArray
}

function Convert-HexToByteArray($hexString) {
	$byteArray = $hexString -replace '^0x', '' -split "(?<=\G\w{2})(?=\w{2})" | %{ [Convert]::ToByte( $_, 16 ) }
	return $byteArray
}

function Convert-Base32ToHex($base32) {
	$base32chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
	$bits = "";
	$hex = "";

	for ($i = 0; $i -lt $base32.Length; $i++) {
		$val = $base32chars.IndexOf($base32.Chars($i));
		$binary = [Convert]::ToString($val, 2)
		$staticLen = 5
		$padder = '0'
		$bits += Add-LeftPad $binary.ToString()  $staticLen  $padder
	}

	for ($i = 0; $i+4 -le $bits.Length; $i+=4) {
		$chunk = $bits.Substring($i, 4)
		$intChunk = [Convert]::ToInt32($chunk, 2)
		$hexChunk = Convert-IntToHex($intChunk)
		$hex = $hex + $hexChunk
	}
	return $hex;
}

function Convert-IntToHex([int]$num) {
	return ('{0:x}' -f $num)
}

function Add-LeftPad($str, $len, $pad) {
	if(($len + 1) -ge $str.Length) {
		while (($len - 1) -ge $str.Length) {
			$str = ($pad + $str)
		}
	}
	return $str;
}

# ============================
#  主循环
# ============================
$accounts = Get-OtpAuthLinks | ForEach-Object { Parse-OtpAuthUrl $_ }
$lastCycle = -1
while ($true) {
	$now = [int]((Get-Date).ToUniversalTime() - [datetime]'1970-01-01').TotalSeconds
	$period = $accounts[0].Period
	$cycle = [Convert]::ToInt64([Math]::Floor($now/$period))
	$remain = $period - ($now % $period)

	if ($cycle -ne $lastCycle) {
		$lastCycle = $cycle
		Clear-Host
		Write-Host "========== 身份验证器 =========="
		foreach ($acc in $accounts) {
			$code = Get-Otp -SECRET $acc.Secret -LENGTH $acc.Digits -WINDOW $acc.Period
			Write-Host ("网站: " + $acc.Issuer)
			Write-Host ("账号: " + $acc.Account)
			Write-Host ("验证码: " + $code)
			Write-Host "----------------------------------------"
		}
	}

	[Console]::SetCursorPosition(0, [Console]::CursorTop)
	Write-Host ("剩余时间: $remain 秒") -NoNewLine
	Start-Sleep -Milliseconds 950
}
