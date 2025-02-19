# Debain系统使用

# 安装

[官方手册](https://www.debian.org/releases/stable/amd64/)

使用vm进行安装，安装的时候选择ssh服务，便于远程连接。

# 系统配置

## 设置静态ip

检查ip

```
ip a
```

切换`root`用户编辑`/etc/network/interfaces`文件

```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug ens33
# iface ens33 inet dhcp
iface ens33 inet static
    address 192.168.234.81
    netmask 255.255.255.0
    gateway 192.168.234.2
    dns-nameservers 8.8.8.8
```

重启网络服务

```
systemctl restart networking
```

> 注意：默认情况下debian是不支持root用户远程登录的。

## 开启root远程登录

为了安全考虑，并不建议这样做。

编辑`/etc/ssh/sshd_config`文件，找到`PermitRootLogin`选项，将其值设置为`yes`

```
PermitRootLogin yes
```

或者，你也可以选择使用 without-password 来允许仅通过 SSH 密钥进行登录，而不允许使用密码进行登录：

```
PermitRootLogin without-password
```

重启ssh服务

```
systemctl restart sshd
```

## sudo权限

默认情况下，普通用户没有sudo权限，无法执行sudo命令，需要先切换到root用户，安装sudo包，并配置sudoers文件。

安装sudo包:

```
su -
apt install sudo
```

添加普通用户到 sudo 用户组，以便该用户可以使用 sudo 命令：

```
usermod -aG sudo username
```

> 我这里是重启系统后生效的。

## 定义alias

编辑`~/.bash_aliases`文件，添加以下内容：

```
alias vi='vim'
alias ll='ls -lh'
alias grep='grep --color=auto'
```

使其生效：

```
source ~/.bash_aliases
```

# tasksel安装图形界面

`tasksel` 是 Debian 和 Ubuntu 中的一个任务选择工具，用于批量安装一组相关的软件包，例如桌面环境、LAMP 服务器、SSH 服务器等。

```
sudo apt install tasksel
sudo tasksel
```

# 软件系统更新

## 换源

```
# 需要切换root用户
sudo su -
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

## 查看使用的源

```
cat /etc/apt/sources.list
```

## 可更新软件列

```
sudo apt list --upgradeable
```

## 更新所有软件

```
sudo apt upgrade
```

## 更新指定的软件

```
sudo apt install package_name
```

## 卸载

```
# 仅卸载软件包
sudo apt remove package_name

# 卸载软件包，并删除配置文件
sudo apt purge package_name
```

## 清理无用的软件

```
sudo apt autoremove
```

# 防火墙

> 在 Debian 上，常用的防火墙管理工具是 iptables 或 nftables。不过，从 Debian 10 (Buster) 开始，nftables 被作为默认的防火墙管理工具，逐渐取代了
> iptables，因为 nftables 提供了更简洁的语法和更高效的性能。

## 切换到iptables防火墙

1. 关闭`nftables`防火墙

```
# 检查 nftables 的服务状态
sudo systemctl status nftables
# 如果看到该服务运行，你可以通过以下命令停止并禁用它
sudo systemctl stop nftables
sudo systemctl disable nftables
```

2. 安装 iptables

```
# 安装 iptables
sudo apt update
sudo apt install iptables
# 查看当前的防火墙规则
sudo iptables -L
# 检查 iptables 模式
sudo update-alternatives --config iptables

```


