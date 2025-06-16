# Redis安装 docker版

**注意：**
- 此安装在CentOS7下进行，请提前确认您有基本的linux操作技能。

- 此安装需要有基本的docker使用能力。[^2]

- 您需要对redis有基本的了解。

## 拉取镜像
```shell
docker pull redis
```

## 准备目录
```shell
# redis文件配置目录
mkdir -p /data/redis/conf
# 持久化文件存放目录
mkdir -p /data/redis/data
```

## 编写配置文件

命名为`redis.conf`，内容填写如下，将文件放入上面建好的`/data/redis/conf`目录中。

可以用github上下载对应版本的配置文件。

```shell
# 使用jsdelivr cdn进行下载，可能存在缓存，和github上的不一致
wget -O redis.conf https://cdn.jsdelivr.net/gh/redis/redis@8.0.0/redis.conf
# 直接在github上进行下载，国内访问可能有问题
wget -O redis.conf https://raw.githubusercontent.com/redis/redis/8.0.0/redis.conf
```

### redis配置文件
```properties
# 在redis容器中使用该文件

# 默认端口6379
# 在redis容器中使用该文件

# 默认端口6379
port 6379

# 密码,默认没有密码
requirepass redis@123

# 数据持久化
appendonly yes
```
如果需要远程访问，可以进行下面的设置
```
bind 0.0.0.0
protected-mode no
```

## redis启动命令
```shell
#redis使用自定义配置文件启动
docker run -v /data/redis/conf:/etc/redis \
-v /data/redis/data:/data \
-d --name myredis \
-p 6379:6379 \
--restart=always \
redis:latest  redis-server /etc/redis/redis.conf
```

启动完成后查看运行情况
```shell
docker ps -a
```
![](https://img2023.cnblogs.com/blog/1745057/202311/1745057-20231101224946319-1606269019.png)

因为启动命令设置了开机自启`--restart=always`，所以下次当docker重启的时候，redis也会自动启动。

## windows redis GUI管理工具`redis-insight`

> 在使用Redis或Redis Stack进行开发时，将您的生产力提升到一个新的水平!使用RedisInsight可视化和优化Redis数据。RedisInsight是一个强大的桌面管理器，为Redis和Redis Stack提供了一个直观高效的UI，并在一个功能齐全的桌面UI客户端中支持CLI交互。[^1]

可以通过[redis官网][redis]下载 `redis-insight`，一键式安装即可。

### 配置连接

- 在主界面点击`ADD REDIS DATABASE`,添加redis数据库。

![](https://img2023.cnblogs.com/blog/1745057/202311/1745057-20231101225957791-1306090555.png)

- 设置redis主机地址，端口默认为`6379`，密码为我们redis.conf设置的密码`redis@123`。点击`Test Connection`检查是否连接成功。

> 别名不知道做什么用的，好像也没多大用途。

![](https://img2023.cnblogs.com/blog/1745057/202311/1745057-20231101230149086-1140373165.png)

[^1]: https://redis.com/redis-enterprise/redis-insight/
[^2]: https://www.cnblogs.com/zjw-blog/p/14025109.html/
[redis]: https://redis.com/redis-enterprise/redis-insight/
