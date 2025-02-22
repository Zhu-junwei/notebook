# 安装 MySQL

# CentOS 7 安装 MySQL 

## 安装

本教程环境为CentOS7，安装MySQL8.0.23确保系统可以连接互联网。

首先确定系统的[mysql已经卸载干净](../uninstall/uninstall.md)。

1. 下载安装 MySQL Yum 仓库
```bash
wget https://repo.mysql.com/mysql80-community-release-el7-11.noarch.rpm
yum localinstall mysql80-community-release-el7-11.noarch.rpm
```

2. 安装 MySQL 8 社区服务器

```bash
yum install mysql-community-server -y
```

3. 启动 MySQL 服务
```bash
systemctl start mysqld
```
4. 显示 root 用户的默认密码

> 安装 MySQL 8.0 时，会自动为 root 用户生成一个临时密码，并记录在日志文件里。请使用以下命令查看 root 用户的临时密码：

```bash
grep "A temporary password" /var/log/mysqld.log
```
这是输出：

```bash
[Note] A temporary password is generated for root@localhost: Liaka*(Dka&^Kjs
```
请注意，您本地的临时密码是不同的。您要根据此密码来更改 root 用户的密码。

5. MySQL 安全配置

执行以下 `mysql_secure_installation` 命令来保护 MySQL 服务器：

```bash
mysql_secure_installation
```
它会提示您输入 root 帐户的当前密码：
```bash
Enter password for user root:
```
输入上面的临时密码，然后按下回车键。将显示以下消息：

```bash
The existing password for the user account root has expired. Please set a new password.

New password:
Re-enter new password:
```
请输入 root 用户的新密码和确认密码。

配置过程中它会提示配置一些安全选项，为了服务器的安全，应该选择 y。这些问题包括：

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y

删除匿名用户？（按 y|Y 表示是，任何其他键表示否）：y

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y

禁止远程 root 登录？（按 y|Y 表示是，任何其他键表示否）：y

Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y

删除测试数据库并访问它？（按 y|Y 表示是，任何其他键表示否）：y

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y

现在重新加载权限表？（按 y|Y 表示是，任何其他键表示否）：y

6. MySQL 服务控制命令

安装完成后，MySQL 服务就会自动启动。我们可以通过以下几个命令查看 MySQL 服务的状态，启动、停止、重启 MySQL 服务器：

CentOS 8 或 CentOS 7

查看 MySQL 服务器状态： `systemctl status mysqld`

启动 MySQL 服务器： `systemctl start mysqld`

停止 MySQL 服务器： `systemctl stop mysqld`

重启 MySQL 服务器： `systemctl restart mysqld`

配置 MySQL 服务器自启动： `systemctl enable mysqld`

7. 连接到 MySQL 服务器

请使用以下命令连接到 MySQL 服务器：

```bash
mysql -u root -p
```

然后根据提示输入 root 帐户的密码，并按 Enter 键。验证通过后，将显示以下输出代表进入了 MySQL 控制台：

```bash
mysql>
```

使用 `SHOW DATABASES` 显示当前服务器中的所有数据库：

```bash
mysql> show databases;
```

这是输出：

```bash
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.05 sec)
```
上面显示的数据库，是 MySQL 服务器自带数据库。

参考

https://dev.mysql.com/downloads/repo/yum/

https://stackoverflow.com/questions/50379839/connection-java-mysql-public-key-retrieval-is-not-allowed

https://www.sjkjc.com/mysql/install-on-centos/

## 设置防火墙
检查防火墙状态：
```bash
sudo systemctl status firewalld
```
如果防火墙未运行，启动它：
```bash
sudo systemctl start firewalld
```
启用防火墙自启动：
```bash
sudo systemctl enable firewalld
```
添加允许 3306 端口的规则：
```bash
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
```
> 这会将 3306 端口添加到 public 区域，并且 --permanent 选项将规则永久保存，使其在系统重启后仍然有效。

重新加载防火墙规则：
```bash
sudo firewall-cmd --reload
```
查看开放的防火墙
```bash
firewall-cmd --list-ports
```

## 设置远程访问

登录到 MySQL 控制台
```bash
mysql -u root -p
```

查看是否存在远程登录的用户
```mysql
SELECT user,host FROM mysql.user;
```
> `localhost`为本地登录，`%`为任意主机登录。

修改或创建远程登录用户的密码

```mysql
-- 创建远程 root 用户，替换 'password' 为你希望设置的密码
CREATE USER 'root'@'%' IDENTIFIED BY 'password';

-- 修改远程 root 用户，替换 'password' 为你希望设置的密码
ALTER USER 'root'@'%' IDENTIFIED BY 'password';
```
MySQL 8 中的默认[密码策略](../password/password.md)规则：

- 密码长度： 密码必须至少有 8 个字符。
- 包含数字、大小写字母和特殊字符： 密码必须包含数字、大写字母、小写字母和特殊字符。

为远程登录用户授权
```mysql
-- 授予 root 用户所有权限，替换 'password' 为你希望设置的密码
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
```

```mysql
-- 刷新权限
FLUSH PRIVILEGES;

-- 退出 MySQL 控制台
EXIT;
```
> 修改完密码或权限后更新后退出


退出登录后重启mysql服务
```bash
systemctl restart mysqld
```

## 密码策略

查看默认的密码策略设置
```mysql
show variables like 'validate_password%';
```
```bash
+-------------------------------------------------+--------+
| Variable_name                                   | Value  |
+-------------------------------------------------+--------+
| validate_password.changed_characters_percentage | 0      |
| validate_password.check_user_name               | ON     |
| validate_password.dictionary_file               |        |
| validate_password.length                        | 8      |
| validate_password.mixed_case_count              | 1      |
| validate_password.number_count                  | 1      |
| validate_password.policy                        | MEDIUM |
| validate_password.special_char_count            | 1      |
+-------------------------------------------------+--------+
8 rows in set (0.00 sec)
```

默认：
- `length`密码的最小长度。在这里，它的值为 8。
- `mixed_case_count`表示密码中必须包含的不同大小写字母的数量。在这里，它的值为 1。
- `number_count`表示密码中必须包含的数字的数量。在这里，它的值为 1。
- `special_char_count`表示密码中必须包含的特殊字符的数量。在这里，它的值为 1。
- `policy`定义了密码强度的策略。在这里，它的值为 MEDIUM，表示中等强度的密码策略。

更改默认设置
```mysql
SET GLOBAL validate_password.length = 6;
SET GLOBAL validate_password.mixed_case_count = 0;
SET GLOBAL validate_password.number_count = 0;
SET GLOBAL validate_password.special_char_count = 0;
```
也可以设置密码的强度策略
```mysql
SET GLOBAL validate_password.length = 4;
SET GLOBAL validate_password.policy=LOW;
```

参考：

https://stackoverflow.com/questions/43094726/your-password-does-not-satisfy-the-current-policy-re

## 卸载
彻底卸载 MySQL 包括删除软件包、清理配置文件、删除数据目录等步骤。以下是在 CentOS 7 上彻底卸载 MySQL 的步骤：

停止 MySQL 服务：
```bash
sudo systemctl stop mysqld
```
移除 MySQL 软件包：

使用 yum 移除 MySQL 软件包：
```bash
sudo yum remove mysql-community-server -y
```
删除 MySQL 相关的数据目录：
```bash
sudo rm -rf /var/lib/mysql
```
删除 MySQL 配置文件：
```bash
sudo rm -rf /etc/my.cnf
```

确认是否有剩余文件：
```bash
ls /etc/ | grep mysql
```
如果还有残留的 MySQL 配置文件，请手动删除。

删除 MySQL 的日志文件：
```bash
sudo rm -rf /var/log/mysqld.log
```
卸载 MySQL 依赖的包（可选）：
```bash
sudo yum autoremove -y
```
清理系统缓存：
```bash
sudo yum clean all
```
更新系统缓存：
```bash
sudo yum makecache
```
重启系统：
```bash
sudo reboot
```

# Debian 12 apt 安装 MySQL

> 在Debain系统通过apt安装MySQL

## 安装

### 安装mysql DEB软件包

[官网位置](https://dev.mysql.com/downloads/repo/apt/)

下载mysql deb包

```
wget https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb
```

安装`gnupg`依赖

```
sudo apt install gnupg
```

这里安装了`gnupg`，如果已安装请忽略。

> `GnuPG`（GNU Privacy Guard，简称 `GPG`）是一个开源的加密软件，用于保护数据的隐私和完整性。它基于 OpenPGP
> 标准，主要用于加密、解密、签名和验证数据。

安装deb包

````
sudo dpkg -i mysql-apt-config_0.8.33-1_all.deb
````

按下方向`↓`键选中`OK`，然后回车。

> 这里默认选中的是`MySQL Server & Cluster (Currently selected: mysql-8.4-lts)`，如果需要其他版本，可以自行选择。


更新系统软件包列表

```
sudo apt update
```

搜索mysql相关包

```
sudo apt search --names-only mysql-server
```

### 安装mysql

通过`apt install`命令安装`mysql-server`

```
sudo apt install mysql-server
```

中间可以设置`root`用户的密码。

查看mysql的状态

```
sudo systemctl status mysql
```

如果看到`active (running)`，表示mysql服务正常运行。

### 配置安全设置

```
sudo mysql_secure_installation
```

```
zjw@debian:~$ sudo mysql_secure_installation

Securing the MySQL server deployment.

Enter password for user root: 

VALIDATE PASSWORD COMPONENT can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD component?

Press y|Y for Yes, any other key for No: 
Using existing password for root.
Change the password for root ? ((Press y|Y for Yes, any other key for No) : 

 ... skipping.
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Success.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : 

 ... skipping.
By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.

Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done!
```

工具会让我们选择设置：
- 是否启用密码的安全性插件 VALIDATE PASSWORD COMPONENT `[回车，不启用]`
- 是否使用已经存在的root密码，如果选择是则需要重新设置 `[直接回车，因为安装的时候设置了]`
- 是否移除匿名用户 `[y，回车，移除]`
- 是否禁止root用户远程访问 `[回车，不禁止]`
- 是否移除test数据库 `[y，回车，移除]`
- 是否立即加载权限表 `[y，回车，加载]`

可以按照自己的需求进行设置。

### 创建远程用户

登录mysql

```
mysql -u root -p
```

创建远程用户

```
CREATE USER 'root'@'%' IDENTIFIED BY '123456';
CREATE USER 'zjw'@'%' IDENTIFIED BY '123456';
```

> 这里创建了远程用户`root`和`zjw`，密码都为`123456`

授权远程用户

```
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'zjw'@'%' WITH GRANT OPTION;
```

查看用户

```
select user,host,plugin from mysql.user;
```

刷新权限

```
FLUSH PRIVILEGES;
exit
```

## 卸载

**停止 MySQL 服务**

在卸载 MySQL 之前，首先需要停止 MySQL 服务：

```
sudo systemctl stop mysql
```

**卸载 MySQL 包**

然后，您可以卸载 MySQL 相关的包。执行以下命令来卸载 MySQL 服务器和相关软件包：

```
sudo apt purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
```

**删除 MySQL 配置文件和数据库文件**

卸载 MySQL 后，还需要删除 MySQL 的配置文件和数据库文件，以确保完全清除 MySQL：

```
sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql /var/log/mysql.*
```

**清理无用的依赖包**

执行以下命令来删除与 MySQL 相关的所有不再需要的依赖包：

```
sudo apt autoremove
```

**删除用户和组（如果需要）**

如果您希望完全删除 MySQL 用户和组（如 mysql），可以执行：

```
sudo deluser mysql
sudo delgroup mysql
```

**清理包缓存（可选）**

如果您想清理 APT 的缓存，可以执行：

```
sudo apt clean
```

**检查 MySQL 是否已完全删除**

您可以使用以下命令确认 MySQL 是否完全卸载

```
dpkg -l | grep mysql
```

如果没有返回任何结果，表示 MySQL 已完全卸载。

**重新启动服务器（可选）**

在卸载完成后，您可以选择重新启动系统：

```
sudo reboot
```

# Debian 安装



# docker

拉取镜像
```
docker pull mysql:8.4.2
```

启动容器
```docker
docker run -d -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=123456 mysql:8.4.2
```