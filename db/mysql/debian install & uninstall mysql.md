# MySQL 8.4 安装指南

本指南将详细介绍如何在 Linux (Debian/Ubuntu) 上手动安装 MySQL 8.4，并进行基本配置。

[MySQL官网](https://dev.mysql.com/doc/refman/8.4/en/general-installation-issues.html)

---

## 1. 安装前准备

### 1.1 更新系统并安装必要依赖

在安装 MySQL 之前，先更新系统包并安装所需的库文件：

```sh
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y libaio1 libnuma1 libncurses6
```

- `libaio1`：异步 I/O 支持库，MySQL 运行所需。
- `libnuma1`：NUMA（非均匀内存访问）支持库，提高性能。
- `libncurses6`：终端用户界面支持库，MySQL 客户端使用。

---

## 2. 下载 MySQL 8.4

```sh
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.4-linux-glibc2.28-x86_64.tar.xz
```

该命令从 MySQL 官方站点下载 MySQL 8.4.4 二进制包。

---

## 3. 创建 MySQL 用户和用户组

为 MySQL 进程创建一个独立用户，确保安全性。

```sh
sudo groupadd mysql
sudo useradd -r -g mysql -s /bin/false mysql
```

- `groupadd mysql`：创建 `mysql` 用户组。
- `useradd -r -g mysql -s /bin/false mysql`：创建 `mysql` 用户，`-r` 选项创建系统用户，`-s /bin/false` 使其无法直接登录。

---

## 4. 安装 MySQL

### 4.1 解压并移动到 /usr/local/

```sh
cd /usr/local
sudo tar xvf ~/mysql-8.4.4-linux-glibc2.28-x86_64.tar.xz
sudo mv mysql-8.4.4-linux-glibc2.28-x86_64 mysql
cd /usr/local/mysql
sudo mkdir mysql-files
sudo chmod 750 mysql-files
```

### 4.2 设置权限

```sh
sudo chown -R mysql:mysql /usr/local/mysql
```

此步骤确保 MySQL 目录归 `mysql` 用户所有，避免权限问题。

---

## 5. 配置环境变量

### 5.1 添加 MySQL 到系统路径

```sh
echo 'export PATH=$PATH:/usr/local/mysql/bin' | sudo tee -a /etc/profile
source /etc/profile
```

这样就可以在任何地方运行 `mysql` 命令。

---

## 6. 配置 MySQL 服务器

### 6.1 创建 my.cnf 配置文件

```sh
cd /etc
sudo touch my.cnf
sudo chown root:root my.cnf
sudo chmod 644 my.cnf
```

### 6.2 编辑 my.cnf

```ini
[mysqld]
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
port=3306
log-error=/usr/local/mysql/data/mysql_error.log
user=mysql
secure_file_priv=/usr/local/mysql/mysql-files
local_infile=OFF
lower_case_table_names=1
```

- `datadir`：数据存储路径。
- `socket`：MySQL 进程使用的 socket 文件。
- `log-error`：错误日志文件路径。
- `lower_case_table_names=1`：表名大小写不敏感（适用于 Windows 兼容性）。

---

## 7. 初始化 MySQL 数据目录

```sh
cd /usr/local/mysql
sudo bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure
```

- `--initialize-insecure`：不生成默认 root 密码，允许手动设置。

---

## 8. 配置 MySQL systemd 服务

### 8.1 创建 systemd 服务文件

```sh
cd /usr/lib/systemd/system
sudo touch mysqld.service
sudo chmod 644 mysqld.service
```

### 8.2 编辑 mysqld.service

```ini
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

# Have mysqld write its state to the systemd notify socket
Type=notify

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Start main service
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf $MYSQLD_OPTS 

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 10000

Restart=on-failure

RestartPreventExitStatus=1

# Set environment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1

PrivateTmp=false
```

### 8.3 重新加载 systemd 并启用服务

```sh
sudo systemctl daemon-reload
sudo systemctl enable mysqld.service
sudo systemctl start mysqld.service
sudo systemctl status mysqld.service
```

---

## 9. 设置 MySQL Root 用户密码

```sh
mysql -u root --skip-password
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
```

此步骤确保 root 用户有密码，防止安全风险。

---

## 10. 验证 MySQL 运行状态

### 10.1 检查数据库列表

```sh
cd /usr/local/mysql
bin/mysqlshow -u root -p
```

### 10.2 查看 MySQL 版本

```sh
bin/mysqladmin -u root -p version
```

---
## 11. 创建远程登录用户（可选）

登录mysql

```
mysql -u root -p
```

创建远程用户

```mysql
CREATE USER 'zjw'@'%' IDENTIFIED BY '123456';
```

> 这里创建了远程用户`zjw`，密码都为`123456`

授权远程用户

```mysql
GRANT ALL PRIVILEGES ON *.* TO 'zjw'@'%' WITH GRANT OPTION;
```

查看用户

```mysql
select user,host,plugin from mysql.user;
```

刷新权限

```mysql
FLUSH PRIVILEGES;
exit
```

## 12. 结论

至此，MySQL 8.4 已成功安装并运行。

---


# MySQL 8.4 卸载步骤

## 1. 停止 MySQL 服务

```sh
sudo systemctl stop mysqld
sudo systemctl disable mysqld
```

## 2. 删除 systemd 配置

```sh
sudo rm -f /usr/lib/systemd/system/mysqld.service
sudo systemctl daemon-reload
```

## 3. 删除 MySQL 用户和用户组（可选）

如果不再需要 `mysql` 用户，可以删除它。

```sh
sudo userdel -r mysql
sudo groupdel mysql
```

## 4. 删除 MySQL 目录

```sh
sudo rm -rf /usr/local/mysql
```

## 5. 删除 MySQL 配置文件

```sh
sudo rm -f /etc/my.cnf
```

## 6. 删除环境变量

从 `/etc/profile` 移除 MySQL 相关的 `PATH` 设置。

```sh
sudo sed -i '/export PATH=\$PATH:\/usr\/local\/mysql\/bin/d' /etc/profile
```

使更改生效：

```sh
source /etc/profile
```

## 7. 清理 MySQL 依赖（可选）

如果安装过程中手动安装了 `libaio1`、`libnuma1` 等库，可以手动卸载它们（**如果其他程序不依赖**）。

```sh
sudo apt-get remove --purge libaio1 libnuma1 libncurses6 -y
sudo apt-get autoremove -y
```

## 8. 确保 MySQL 已完全卸载

```sh
which mysql  # 确保找不到 mysql
mysql --version  # 应该报错
```

## 9. 注销并重新登录（推荐）

为了确保所有环境变量更改生效，建议注销当前用户并重新登录。
