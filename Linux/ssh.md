## 登录

常见用法

```
ssh zjw@100.109.182.40
```

指定端口

```
ssh zjw@100.109.182.40 -p 8022
```

## 计算公钥指纹

```
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHj9+kVoeb67ubS/o3iagnuPjRVj6ocwsJa4z8Q0g6oI" | ssh-keygen -lf -
```

## 生成密钥

**rsa**

生成一个 **RSA** 类型的密钥，默认位数是 **2048 位**，你也可以指定更大的位数（比如 4096 位）

```
ssh-keygen -t rsa -b 4096 -C "zjw@windows" -f $env:USERPROFILE\.ssh\id_rsa
```

`-b` 选项用来指定密钥的位数（默认为 2048，推荐使用 4096 来增强安全性）。

**ecdsa**
 生成一个 **ECDSA**（Elliptic Curve Digital Signature Algorithm）类型的密钥。
 ECDSA 密钥比 RSA 更小且安全性更高。你可以指定曲线类型（如 `nistp256`、`nistp384`、`nistp521`）。
 命令示例：

```
ssh-keygen -t ecdsa -b 521 -C "zjw@windows" -f $env:USERPROFILE\.ssh\id_ecdsa
```

**ed25519**

生成一个 **Ed25519** 类型的密钥，这是一种非常安全且快速的椭圆曲线密钥算法，越来越受欢迎。

```
ssh-keygen -t ed25519 -C "zjw@windows" -f .ssh\id_ed25519
```

~~**dss**~~

 生成一个 DSS（数字签名算法）类型的密钥。
 但此类型在现代 SSH 实现中不再推荐使用，因为它相对较弱，基本不再被支持。