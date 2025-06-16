[TOC]

# 下载

# 官网下载

[https://www.kali.org/get-kali/#kali-virtual-machines](https://www.kali.org/get-kali/#kali-virtual-machines)

# WMware导入及登录

1. WMware扫描解压出来的kali压缩包
2. 启动kali系统，默认用户名和密码都为`kali`
3. 设置系统为中文编码 [教程](https://blog.csdn.net/luweisuccess/article/details/115720139)

# 安装配置

## 选择不更新Metasploit

```shell
1.查看当前的系统中所有软件包状态
sudo dpkg --get-selections | more
2.给metasploit-framework锁定当前版本不更新
sudo apt-mark hold metasploit-framework
3.查看当前已锁定的软件包
sudo dpkg --get-selections | grep hold
4.取消软件保留设置
sudo apt-mark unhold metasploit-framework
```

## 配置kali系统源

```shell
vim /etc/apt/sources.list

# 清华源
deb http://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
deb-src https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
```

或者使用下面的命令选择愿

```bash
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

更新源

```bash
apt update && apt upgrade
```

## sshd设置

```shell
vim /etc/ssh/sshd_config
```

修改下面两个配置项

```shell
PasswordAuthentication yes
PermitRootLogin yes
```

开启ssh服务

```ssh
-- 开启服务
service ssh start
-- 查看状态
service ssh status
-- 停止服务
service ssh stop
```

设置ssh开机自启动

```ssh
update-rc.d ssh enable
```

取消关机自启动

```
update-rc.d ssh disable
```

# 常用命令

## dpkg

> dpkg是一个Debian的一个命令行工具，它可以用来安装、删除、构建和管理Debian的软件包。

### 安装软件

```
dpkg -i xxx.deb
```

### 卸载软件

```
-- 删除软件包
dpkg -r xxx.deb
-- 联通配置文件一起删除
dpkg -r --purge xxx.deb
```

## gedbi

> gedbi是一个轻量级的deb安装工具，它能替代臃肿的ubuntu软件中心安装deb

### 安装gedbi

```
sudo apt-get update
sudo apt-get install gdebi
```

### 安装软件

```
-- 方式1
sudo gdebi sogoupinyin.deb --选择y即可
-- 方式2
双击deb文件安装或者卸载
```

# 信息收集

对于Web渗透测试而言、针对目标系统所相关的信息


| 框架     | 开发人员                                  | 安全人员                                                  |
| -------- | ----------------------------------------- | --------------------------------------------------------- |
| 前端     | HTML/CSS/JS......                         | 指纹识别<br />GITHUB/源代码泄露<br />敏感文件及地址<br /> |
| 后端     | PHP/ASP.NET/容器/数据库……               | 框架识别<br />容器识别                                    |
| 中间件   | 就是中间件                                | 组件报错                                                  |
| 系统     | windows server<br />linux<br />mac server | 端口<br />系统识别                                        |
| 网络架构 | osi模型                                   | 域名<br />Whois<br />CDN<br />c段                         |

## 搜索引擎&Google语法

```
site:qq.com
intitle:"QQ飞车"
intext:"活动"
```

```
--网络摄像头
intitle:"netbotz appliance" "ok"
--查找后台
inurl:"/admin/login.php"
inurl:qq.txt
filetype:xls "username | password"
filetype:xls "密码"
filetype:xls "身份证"
intext:password "Login Info" filetype:txt
```

> Google Hacking Database

https://www.exploit-db.com/google-hacking-database

爬虫的文件

```
/rebots.txt
```

### 网络空间搜索引擎

> 基于物联网搜索，搜索联网的网络设备

钟馗之眼  [https://www.zoomeye.org](https://www.zoomeye.org/)

Shodan [https://www.shodan.io/](https://www.shodan.io/)

fofa [https://fofa.so/](https://fofa.so/)

傻蛋 [https://www.oshadan.com/](https://www.oshadan.com/)

Dnsdb搜索  [DNSDB](https://www.dnsdb.io/zh-cn/)

### 精细化搜索

[微信公众号](https://weixin.sogou.com/)

[知乎](https://www.zhihu.com/search?type=content&q=)

[微博](https://s.weibo.com/)

[购物](https://search.jd.com/)

github

[贴吧](https://tieba.baidu.com/f/search/res)

==撰写信息收集报告==

## 端口扫描-NMAP

## 子域名&&目录扫描

## 指纹识别-云悉

# 重置root密码

1.系统启动时时按下`e`

2.倒数第三行`ro`改为`rw`，本行结尾加上`init=/bin/bash`,`F10`保存

3.进入系统后输入`passwd root`重置root密码
