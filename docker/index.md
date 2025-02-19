# Docker安装与卸载

[官方文档](https://docs.docker.com/engine/install/)选择对应的系统。

## CentOS

### Docker 卸载

停止并删除所有运行中的容器

```bash
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
```

删除所有镜像

```bash
sudo docker rmi $(sudo docker images -q)
```

禁用docker的开机自启

> 如果设置了开机自启

```bash
sudo systemctl disable docker
```

> 可以通过`systemctl status docker`命令查看是否开启了docker的自启动。如果loaded是enabled代表是开机自启，否则没有设置开启自启。

停止Docker服务

```bash
# 关闭docker.socket
sudo systemctl stop docker.socket
# 关闭docker
sudo systemctl stop docker
```

卸载Docker软件包

```bash
sudo yum remove docker-ce docker-ce-cli containerd.io -y
```

删除Docker数据和配置

```bash
sudo rm -rf /var/lib/docker
```

删除Docker存储库

```bash
sudo yum remove docker-ce docker-ce-cli containerd.io \
                    docker-buildx-plugin.x86_64 \
                    docker-compose-plugin.x86_64 -y
```

清理yum缓存

```bash
sudo yum clean all
```

检查并删除可能存在的其他Docker组件

```bash
sudo yum list installed | grep docker
```

如果有的话使用如下命令进行删除

```bash
sudo yum remove xxx
```

### Docker安装

该步骤适用于CentOS 7系统。最新版本参考[官方文档](https://docs.docker.com/engine/install/centos/)。

安装依赖包

```bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

添加Docker存储库

> 二选一

```bash
# docker官网
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 阿里云
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

安装Docker引擎

```bash
sudo yum install docker-ce docker-ce-cli containerd.io -y
```

启动Docker服务

```bash
sudo systemctl start docker
```

设置Docker服务随系统启动

```bash
sudo systemctl enable docker
```

验证安装

```bash
sudo docker --version
```

显示结果

```
[root@Redis ~]# sudo docker --version
Docker version 24.0.7, build afdd53b
```

（可选）将用户添加到docker组（避免使用sudo）

```bash
sudo usermod -aG docker your_username
```

请将your_username替换为你的实际用户名。然后，注销并重新登录以应用更改。

## Debian

[官方文档](https://docs.docker.com/engine/install/debian)

### 先决条件

**防火墙设置**

因为`Docker`仅与`iptables-nft`和`iptables-legacy`兼容。我使用的`dobian 12`默认使用的是`nftables`防火墙。这里需要先切换一下。

参看[Linux Debian防火墙配置教程](../Linux/debain/README.md)

### Docker卸载

卸载所有相互冲突的软件包

```
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

卸载 Docker Engine, CLI, containerd, 和 Docker Compose packages:

```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```

主机上的镜像，容器，卷或自定义配置文件不会自动删除。删除所有镜像，容器和卷：

```
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

删除源列表和密钥文件

```
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/keyrings/docker.asc
```

### Docker安装

> 这里采用的是apt进行安装

在首次在新的主机机器上安装Docker Engine之前，您需要设置Docker apt存储库。之后，您可以从存储库安装和更新Docker。

1. 设置Docker的apt存储库。

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

2. 安装最新版 Docker 软件包。

```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3. 通过运行hello-world映像验证安装是否成功：

```
sudo docker run hello-world
```

# docker compose使用

[docker-compose](./docker%20compose.md)

# docker其他文档

参考：https://www.cnblogs.com/zjw-blog/category/1886775.html