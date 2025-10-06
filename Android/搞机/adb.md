
以下是更全面的ADB命令列表

一、设备管理
- `adb devices`: 列出当前连接的设备及其状态。
- `adb get-serialno`: 获取设备的序列号。
- `adb kill-server`: 停止ADB服务。
- `adb start-server`: 启动ADB服务。
- `adb connect <IP地址>`: 通过IP地址连接设备（适用于无线调试）。
- `adb disconnect`: 断开所有连接设备或指定设备。

二、文件传输
- `adb push <本地文件路径> <设备路径>`: 将文件从本地传输到设备。
- `adb pull <设备文件路径> <本地路径>`: 将文件从设备传输到本地。
- `adb backup -apk -shared -all -f <backup.ab>`: 备份设备数据到本地文件。
- `adb restore <backup.ab>`: 恢复备份文件到设备。

三、应用管理
- `adb install <apk文件路径>`: 安装APK到设备。
- `adb install -r <apk文件路径>`: 覆盖安装已存在的应用。
- `adb install-multiple <apk文件1> <apk文件2>`: 安装带有分离APK的应用。
- `adb install -t <apk文件路径>`: 安装允许测试的APK。
- `adb uninstall <包名>`: 卸载指定应用。
- `adb shell pm list packages`: 列出设备上安装的所有应用包名。
- `adb shell pm path <包名>`: 查看应用的安装路径。
- `adb shell pm disable-user --user 0 <包名>`: 禁用指定应用。
- `adb shell pm enable <包名>`: 启用指定应用。

四、系统控制
- `adb reboot`: 重启设备。
- `adb reboot bootloader`: 重启进入引导模式。
- `adb reboot recovery:` 重启进入恢复模式。
- `adb remount`: 重新挂载系统分区为读写模式（需要root权限）。
- `adb root`: 以root权限重新启动ADB服务（需要设备已root）。

五、日志查看
- `adb logcat`: 实时查看设备日志。
- `adb logcat -d > log.txt`: 保存当前日志到文件。
- `adb logcat -c`: 清空设备日志缓存。
- `adb logcat -s <tag>`: 按指定TAG过滤日志信息。

六、Shell命令
- `adb shell`: 进入设备的Shell交互环境。
- `adb shell <command>`: 在设备上执行指定的Shell命令。
- `adb shell top`: 查看设备的实时进程状态。
- `adb shell dumpsys`: 显示设备当前系统服务状态信息。
- `adb shell getprop`: 显示设备的系统属性。
- `adb shell setprop <属性> <值>`: 设置系统属性（需要root权限）。
- `adb shell screencap /sdcard/screenshot.png`: 在设备上截图并保存。

七、屏幕和输入
- `adb shell input text <文本>`: 模拟输入文本。
- `adb shell input keyevent <keycode>`: 模拟按键事件。
- `adb shell input tap <x> <y>`: 模拟屏幕点击。
- `adb shell input swipe <x1> <y1> <x2> <y2> <duration>`: 模拟屏幕滑动。

八、端口转发
- `adb forward <本地端口> <远程端口>`: 将本地端口转发到设备端口。
- `adb forward --remove <本地端口>`: 移除端口转发。
- `adb forward --list`: 列出所有活动的端口转发。

九、网络管理
- `adb shell ifconfig`: 查看设备的网络配置信息。
- `adb shell netstat`: 查看网络连接状态。
- `adb shell ping <主机>`: 测试网络连通性。
- `adb shell ip route`: 查看路由信息。

十、文件系统
- `adb shell ls <路径>`: 列出设备指定目录的文件。
- `adb shell rm <路径>`: 删除设备上的文件。
- `adb shell mkdir <路径>`: 在设备上创建目录。
- `adb shell mv <源路径> <目标路径>`: 移动或重命名设备上的文件。

十一、调试和开发
- `adb bugreport > bugreport.txt`: 生成设备的bug报告。
- `adb jdwp`: 列出设备上所有正在运行的JDWP（Java Debug Wire Protocol）进程。
- `adb shell am start -n <包名>/<活动名>`: 启动指定应用的Activity。
- `adb shell am force-stop <包名>`: 强制停止应用。

十二、系统权限和配置
- `adb shell settings get <namespace> <key>`: 获取系统设置的值。
- `adb shell settings put <namespace> <key> <value>`: 设置系统设置的值。
- 
这些ADB命令覆盖了设备管理、应用管理、文件传输、系统控制、调试、网络、输入模拟等功能，可以满足绝大多数的Android设备开发和调试需求。