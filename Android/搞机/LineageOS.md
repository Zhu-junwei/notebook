1. 下载room包
通常是zip格式

2. 下载boot.img

关机后使用`电源键`+`音量-`进入fastboot模式。

查看设备连接情况
```
fastboot devices
```

刷入boot.img
```
fastboot flash boot boot.img 
```
双清

刷入系统
```
adb sideload lineage-22.1.xxxx.zip
```


## 优化设置

### 网络验证
```
adb shell settings put global captive_portal_https_url https://connect.rom.miui.com/generate_204
adb shell settings put global captive_portal_http_url http://connect.rom.miui.com/generate_204

```

### 时间同步

```
adb shell settings put global ntp_server ntp.aliyun.com

```
