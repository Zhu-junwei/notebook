# WSL

什么是wsl?

> WSL (Windows Subsystem for Linux) 是 Windows 10 和 Windows Server 2016 的一项功能，允许用户在 Windows 上运行 Linux 二进制文件。

# 安装WSL
powershell管理员模式运行：
```
wsl --install
```
```
PS C:\Users\jw> wsl --install
正在下载: 适用于 Linux 的 Windows 子系统 2.4.11
正在安装: 适用于 Linux 的 Windows 子系统 2.4.11
已安装 适用于 Linux 的 Windows 子系统 2.4.11。
正在安装 Windows 可选组件: VirtualMachinePlatform

部署映像服务和管理工具
版本: 10.0.26100.1150

映像版本: 10.0.26120.3281

启用一个或多个功能
[==========================100.0%==========================]
操作成功完成。
请求的操作成功。直到重新启动系统前更改将不会生效。
请求的操作成功。直到重新启动系统前更改将不会生效。
```

安装完成后重启电脑。

# 列出可用的发行版
```
wsl --list --online
```

# 通过wsl安装debian
```
wsl --install debian
```

安装完成后会让设置用户名和密码。

# 登录到debian
```
wsl
```

# 修改root密码

```
sudo passwd root
```