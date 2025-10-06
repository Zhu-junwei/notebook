# vmware扩容

前提：

- 关闭虚拟机
- 需要系统分区的剩余容量要是扩容容量的2倍。（必须需要扩容到50G，则当前虚拟机的磁盘分区要有100G的空闲）

## 增加容量

编辑虚拟机，硬盘里面点击`扩展`，设置指定的`最大磁盘大小`，我这里是要设置为`400G`

## 打开虚拟机调整大小

1. **进入系统后，确认磁盘已扩容**

```
lsblk
fdisk -l
```

可以看到虚拟硬盘的容量已经变大了（例如从 100G → 400G），但已有分区大小没变。

2. **调整分区**

- 如果是 MBR 分区，可以用 fdisk；
- 如果是 GPT 分区，可以用 gdisk 或 parted。

常见操作（以根分区 /dev/sda1 为例）：

```
sudo parted /dev/sda
(parted) print   # 查看分区情况
(parted) resizepart 1 100%   # 把 sda1 扩展到最大
(parted) quit
```

3. **扩展文件系统**

确认文件系统类型及硬盘情况：

```
df -Th
```

如果是 ext4 ：

```
sudo resize2fs /dev/sda1
```

如果是 xfs：

```
sudo xfs_growfs /
```

验证扩容结果

```
df -h
```

## 重新设置Swap（可选）

如果之前 swap 太小或者放在了单独分区，可以删除旧的重新建：

1. **关闭旧 swap**

```
sudo swapoff -a
```

2. 新建 swap 文件（例如 16G）

```
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

3. 写入 fstab 保持开机自动挂载

```
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

