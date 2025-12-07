Add-Type -AssemblyName System.Device
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher

# 仅获取一次位置，提高效率
$GeoWatcher.MovementThreshold = 1
$GeoWatcher.Start()

Write-Output "正在获取GPS位置信息，请稍候..."
$timeout = 15  # 最长等待 15 秒

while (($GeoWatcher.Status -ne "Ready" -or $GeoWatcher.Position.Location.IsUnknown) -and $timeout -gt 0) {
    Start-Sleep -Seconds 1
    $timeout -= 1
}

$Location = $GeoWatcher.Position.Location

# 判断是否成功获取位置
if ($Location.IsUnknown) {
    Write-Output "无法获取位置信息，请确保设备已启用定位服务。"
} else {
    # 获取经纬度
    $lat = $Location.Latitude
    $lon = $Location.Longitude

    Write-Output "位置信息获取成功："
    Write-Output "   纬度 (Latitude):  $lat"
    Write-Output "   经度 (Longitude): $lon"

    # 获取海拔高度
    $altitude = $Location.Altitude
    if ([double]::IsNaN($altitude)) {
        Write-Output "   海拔高度 (Altitude): 不支持"
    } else {
        Write-Output "   海拔高度 (Altitude): $altitude 米"
    }

    # 获取水平精度
    $horizontalAccuracy = $Location.HorizontalAccuracy
    Write-Output "   水平精度 (Horizontal Accuracy): $horizontalAccuracy 米"

    # 获取垂直精度
    $verticalAccuracy = $Location.VerticalAccuracy
    if ([double]::IsNaN($verticalAccuracy)) {
        Write-Output "   垂直精度 (Vertical Accuracy): 不支持"
    } else {
        Write-Output "   垂直精度 (Vertical Accuracy): $verticalAccuracy 米"
    }

    # 获取速度
    $speed = $Location.Speed
    if ([double]::IsNaN($speed)) {
        Write-Output "   速度 (Speed): 不支持"
    } else {
        Write-Output "   速度 (Speed): $speed 米/秒"
    }

    # 获取方向
    $course = $Location.Course
    if ([double]::IsNaN($course)) {
        Write-Output "   方向 (Course): 不支持"
    } else {
        Write-Output "   方向 (Course): $course 度"
    }

    # 获取时间戳并转换为本地时间
    $timestamp = $GeoWatcher.Position.Timestamp
    $localTime = $timestamp.DateTime.ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss")
    Write-Output "   时间戳 (Timestamp): $localTime"
}

Pause