# Scoop 使用指南



> [Scoop](https://scoop.sh/) :  Windows的命令行安装程序。

Scoop 让你从命令行安装你熟悉和喜爱的程序，且尽量减少麻烦。它的特点包括：

- **消除权限弹窗**：避免权限请求弹窗的干扰。
- **隐藏图形界面的安装向导**：不需要通过图形界面的安装向导。
- **防止 PATH 污染**：避免在安装大量程序时污染系统的 PATH 环境变量。
- **避免安装和卸载程序时的意外副作用**：安装和卸载程序时，不会产生意外的副作用。
- **自动查找并安装依赖**：自动处理程序所需的依赖项安装。
- **自动执行额外的设置步骤**：自动完成程序运行所需的额外配置和设置。

## 安装Scoop

### 依赖项

Scoop 需要 PowerShell，在安装 Scoop 之前，确保系统满足以下要求：

- Windows 10 或更高版本

- PowerShell 5.1 或更高版本

### 安装方式一：典型安装方式

PowerShell[ 执行策略](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)必须是`RemoteSigned`、`Unrestricted`或`ByPass`之一，才能运行安装程序。例如，可以通过以下方式将其设置为`RemoteSigned`：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

从**非管理员**的 PowerShell 上执行此命令，安装 scoop，默认配置，scoop 将安装到 `C:\Users\<你的用户名>\scoop` 。
```powershell
irm get.scoop.sh | iex
```

### 安装方式二： 高级安装

默认情况下，Scoop 安装在 `C:\Users\<你的用户名>\scoop` 目录。如果想更改安装目录，例如希望 Scoop 安装到 `D:\software\scoop`，最好采用手动安装，在 PowerShell 中运行以下命令：

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

irm get.scoop.sh -outfile 'install.ps1'

.\install.ps1 -ScoopDir 'D:\software\scoop' -ScoopGlobalDir 'D:\scoop_global' -NoProxy
```

大部分情况下我们的电脑只有一个账户在使用，安装的应用都是针对当前用户的，如果安装的应用需要对所有用户都使用，可以通过`-ScoopGlobalDir`参数来设置全部用户使用的应用位置。

需要注意的是`-ScoopDir` `ScoopGlobalDir`都需要进行设置，尽管你只是自己在使用电脑。

## 帮助命令

可以使用`scoop --version`来查看版本信息，使用`scoop`命令查看[帮助文档](https://github.com/ScoopInstaller/Scoop/wiki)。

```shell
# 查看版本
scoop --version

# 帮助信息
scoop

C:\Users\jw>scoop
Usage: scoop <command> [<args>]

Available commands are listed below.

Type 'scoop help <command>' to get more help for a specific command.

Command    Summary
-------    -------
alias      Manage scoop aliases
bucket     Manage Scoop buckets
cache      Show or clear the download cache
cat        Show content of specified manifest.
checkup    Check for potential problems
cleanup    Cleanup apps by removing old versions
config     Get or set configuration values
create     Create a custom app manifest
depends    List dependencies for an app, in the order they'll be installed
download   Download apps in the cache folder and verify hashes
export     Exports installed apps, buckets (and optionally configs) in JSON format
help       Show help for a command
hold       Hold an app to disable updates
home       Opens the app homepage
import     Imports apps, buckets and configs from a Scoopfile in JSON format
info       Display information about an app
install    Install apps
list       List installed apps
prefix     Returns the path to the specified app
reset      Reset an app to resolve conflicts
search     Search available apps
shim       Manipulate Scoop shims
status     Show status and check for new app versions
unhold     Unhold an app to enable updates
uninstall  Uninstall an app
update     Update apps, or Scoop itself
virustotal Look for app's hash or url on virustotal.com
which      Locate a shim/executable (similar to 'which' on Linux)
```

## scoop配置

可以用过`soop config`来查看配置信息

```
scoop config
```

可以使用`--help`来获取更多的帮助信息

```
scoop config --help
```

### aria2设置

如果安装了`aria2`，scoop可以通过`aria2`进行多线程下载。我们也可以手动开启关闭`aria2`使用。

```
# 禁用aria2
scoop config aria2-enabled false
# 启用aria2
scoop config aria2-enabled true
# 删除aria2配置
scoop config rm aria2-enabled
```

### 设置代理下载

由于scoop管理的软件大部分下载地址都是在国外，所以使用系统的代理（前提你有可用的代理）进行加速是很有必要的。

```
# 设置代理
scoop config proxy 127.0.0.1:7890
# 如果不需要，可以清除代理
scoop config rm proxy
```

## bucket管理

>  bucket 是 Scoop 的一个概念，它允许用户添加额外的软件源，以便在 Scoop 中安装更多软件，一般情况不同的bucket存放不同的软件源。

```powershell
# 列出已安装的 bucket
scoop bucket list
# 列出已知的 bucket
scoop bucket known
# 添加新的 bucket，添加bucket需要先安装有git
scoop bucket add java
# 卸载一个bucket
scoop bucket rm main

------------------------
# 添加bucket
------------------------
# 添加第三方的 bucket 根据需要添加删除自带的bucket，用来安装应用,这里有github和gitee，根据自己情况选择添加
# -- github
scoop bucket add main
scoop bucket add extras
scoop bucket add dorado https://github.com/chawyehsu/dorado
# -- gitee
scoop bucket add main https://gitee.com/cmontage/scoopbucket
scoop bucket add dorado https://gitee.com/scoop-bucket/dorado
```

## 安装和卸载软件

### 搜索软件

可以使用 `Scoop` 搜索软件，例如搜索  `7zip`：
```powershell
scoop search 7zip
```

### 安装软件

可以使用 `Scoop` 安装软件，例如安装 `7zip`：
```powershell
scoop install 7zip
```

### 更新软件

```
# 更新指定软件
scoop update 7zip

# 更新所有软件 
scoop update *
```

### 软件锁定与解锁

> 如果你不需要软件进行更新，可以使用`hold`锁定版本。使用`unhold`解除锁定。

```
# 锁定版本
scoop hold 7zip

# 解除锁定
scoop unhold 7zip
```

### 卸载软件

如果要卸载已安装的软件，例如 7zip，可以运行：
```
scoop uninstall 7zip
```


## 设置自动更新（可选）

**打开任务计划程序**

   按 Win + S，搜索“任务计划程序”并打开。

**创建基本任务**

   在右侧点击“创建基本任务”。

   输入任务名称（如“Scoop Daily Update”）和描述，点击“下一步”。

**触发器**

  设置每天

  设置一个每天执行的时间，比如`15:00:00`，每隔`1`天发生一次。

**操作**

  选择`启动程序`

  程序或脚本设置为`powershell`，添加参数设置为`-WindowStyle Hidden -File "E:\code\IdeaProjects\notebook\windows\shell\powershell\shell\scoop_update.ps1"`。

> 脚本替换为自己的路径

`scoop_update.ps1`

```shell
scoop update *
scoop cache rm *
scoop cleanup *
scoop export | Out-File -FilePath scoopfile.json -Encoding utf8
```

这里的作用是：

- 更新所有scoop及其安装的应用
- 清理下载的应用安装包
- 清理旧的应用
- 将所有安装的应用保存到一个json文件里面，可以方便对已经安装应用做一个备份，如果重装系统或在另外一个电脑上可以通过`scoop import xxx.json` 进行快速恢复

**验证任务**

   在任务计划程序库中找到该任务，右键选择“运行”以测试。

## 卸载Scoop

**1. 卸载scoop**

如果需要完全卸载 Scoop，可以按照以下步骤进行：

```
# 卸载scoop，这会卸载通过scoop安装的所有应用及scoop本身
scoop uninstall scoop
```

已安装的程序可能**正在运行**或在系统中存在**服务**，需要退出正在运行的程序或删除程序对应的服务后再进行卸载。

```
# 管理员删除程序的服务（如果有）
sc delete <服务名字>
```

**2. 删除 Scoop 目录**

- 默认安装删除

找到 Scoop 安装目录（默认在 `C:\Users\你的用户名\scoop`），然后运行以下命令删除：
```powershell
Remove-Item -Recurse -Force "C:\Users\$env:UserName\scoop"
```

- 自定义安装删除

如果是scoop的路径是自定义的，需要手动删除。

**3. 重新启动计算机**

执行完上述命令后，建议重启计算机以使更改生效。

🎉 以上就是 Scoop 的完整安装、卸载、目录更改、软件管理和备份恢复的详细指南，希望对你有所帮助！ 🚀