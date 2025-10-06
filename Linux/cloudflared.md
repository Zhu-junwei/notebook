## 安装 cloudflared

Debian Bookworm

参考：

[Downloads](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)

[pkg.cloudflare.com/index.html#debian-any](https://pkg.cloudflare.com/index.html#debian-any)

```
# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo apt-get update && sudo apt-get install cloudflared
```

## 升级

```
sudo apt-get update && sudo apt-get install --only-upgrade cloudflared
```

## 验证

```
cloudflared --version
which cloudflared
```

## 登录

```
sudo cloudflared login
```

点击连接跳转到选择`域`的界面，授权后即可登录成功。

## tunnel管理

```bash
# 查看已创建tunnel列表
sudo cloudflared tunnel list
# 创建tunnel
sudo cloudflared tunnel create win-debian
# 删除tunnel
sudo cloudflared tunnel delete win-debian
# 帮助信息
cloudflared tunnel help
cloudflared tunnel info <UUID or NAME>
```

## 创建config.yml

参考：[Configuration file](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/configuration-file/)

创建`config.yml`配置文件

```bash
sudo touch /etc/cloudflared/config.yml
```

配置config.yml

```bash
sudo vim /etc/cloudflared/config.yml
```

```yml
tunnel: 6ff42ae2-765d-4adf-8112-31c55c1551ef
credentials-file: /root/.cloudflared/6ff42ae2-765d-4adf-8112-31c55c1551ef.json

ingress:
  - hostname: gitlab.widgetcorp.tech
    service: http://localhost:80
  - hostname: gitlab-ssh.widgetcorp.tech
    service: ssh://localhost:22
  - service: http_status:404
```

> 这里需要填写刚才创建的tunnel id，可以通过`sudo cloudflared tunnel list`

验证配置

```bash
sudo cloudflared tunnel ingress validate
```

## 系统服务

根据官方文档[配置 cloudflared 参数](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/cloudflared-parameters/#update-tunnel-run-parameters)，是会创建服务的，但是我根据上面的安装步骤，发现并没有安装为服务，所以我使用下面的步骤创建了服务。

```bash
# 安装服务，这个需要配置文件的支持，所以要先创建config.yml配置文件
sudo cloudflared service install
# 开机自启，这个在安装服务后默认是开启的
sudo systemctl enable cloudflared
# 关闭开机自启
sudo systemctl disable cloudflared
# 卸载服务
sudo cloudflared service uninstall
# 编辑配置，有需要了可以修改
sudo systemctl edit --full cloudflared.service
# 重启
sudo systemctl status cloudflared
sudo systemctl stop cloudflared
sudo systemctl restart cloudflared
```

## DNS记录设置

```bash
# 添加CNAME记录
sudo cloudflared tunnel route dns win-debian gitlab-ssh.widgetcorp.tech
# 删除CNAME记录
sudo cloudflared tunnel route dns delete gitlab-ssh.widgetcorp.tech
```

## 查看日志

```
sudo journalctl -u cloudflared -f
```

## 运行tunnel

```
# 使用默认配置
sudo cloudflared tunnel run <UUID or NAME>
# 指定配置文件
sudo cloudflared tunnel --config /path/your-config-file.yml run <UUID or NAME>
```

> 这个是在前台运行，可以使用nohup运行在后台或使用systemctl在后台运行

## 远程连接ssh

前面我们已经通过`ssh://localhost:22`配置为ssh设置了代理，我们可以把你的本地端口 2222 映射到远程 SSH 服务，需要提前安装cloudflared

```
cloudflared access ssh --hostname gitlab-ssh.widgetcorp.tech --url ssh://localhost:2222
```

这时候会显示远程的ssh版本信息，再打开一个终端连接2222

```
ssh -p 2222 用户名@localhost
```

输入密码就可以连接了