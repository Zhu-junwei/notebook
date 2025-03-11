# 🚀 Scoop 使用指南

## 安装 🏗️ Scoop

### ⚙️ 依赖项

Scoop 需要 💻 PowerShell，在安装 Scoop 之前，确保系统满足以下要求：

- Windows 10 或更高版本

- PowerShell 5.1 或更高版本

### ▶️ 运行 Scoop 安装命令

在 PowerShell 中运行以下命令：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

然后安装 Scoop：
```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

安装完成后，可以运行以下命令检查 Scoop 是否安装成功：
```
scoop --version
```

## 自定义 Scoop 📂 安装目录

默认情况下，Scoop 安装在 `C:\Users\你的用户名\scoop` 目录。如果想更改安装目录，需要在安装前手动设置环境变量 `SCOOP`。

### 🔄 自定义安装目录

例如，如果希望 Scoop 安装到 `D:\software\scoop`，最好采用手动安装：

然后重新运行 Scoop 安装命令：
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1" -OutFile "install.ps1"

.\install.ps1 -ScoopDir 'D:\software\scoop' -ScoopGlobalDir 'D:\scoop_global' -NoProxy
```

## bucket管理

>  bucket 是 Scoop 的一个概念，它允许用户添加额外的软件源，以便在 Scoop 中安装更多软件。

```powershell
# 列出已安装的 bucket
scoop bucket list
# 列出已知的 bucket
scoop bucket known
# 添加新的 bucket
scoop bucket add java

# 添加第三方的 bucket 根据需要添加删除自带的bucket，
scoop config SCOOP_REPO "https://gitee.com/scoop-installer/scoop"
scoop bucket add main https://gitee.com/cmontage/scoopbucket
scoop bucket add dorado https://github.com/chawyehsu/dorado
scoop bucket add dorado https://gitee.com/scoop-bucket/dorado
scoop bucket add abgo_bucket https://gitee.com/abgox/abgo_bucket
scoop bucket add third https://gitee.com/cmontage/scoopbucket-third

```

## 安装 🛠️ 和卸载 ❌ 软件

### 📦 搜索软件

可以使用 `Scoop` 搜索软件，`例如搜索` `7zip`：
```powershell
scoop search 7zip
```

### 📦 安装软件

可以使用 `Scoop` 安装软件，例如安装 `7zip`：
```powershell
scoop install 7zip
```

### 🗑️ 卸载软件

如果要卸载已安装的软件，例如 7zip，可以运行：
```
scoop uninstall 7zip
```

## 设置自动更新

### 1. 打开任务计划程序
   按 Win + S，搜索“任务计划程序”并打开。

### 2. 创建基本任务
   在右侧点击“创建基本任务”。

输入任务名称（如“Scoop Daily Update”）和描述，点击“下一步”。

### 3. 设置触发器
   选择“每天”，点击“下一步”。

设置开始时间和日期，点击“下一步”。

### 4. 选择操作
   选择“启动程序”，点击“下一步”。

### 5. 配置操作
   在“程序或脚本”框中输入 powershell。

   在“添加参数”框中输入 -WindowStyle Hidden -Command "scoop update *"，点击“下一步”。

### 6. 完成设置
   确认信息无误，点击“完成”。

### 7. 验证任务
   在任务计划程序库中找到该任务，右键选择“运行”以测试。

## 卸载 🗑️ Scoop

如果需要完全卸载 Scoop，可以按照以下步骤进行：

### ❌ 先卸载所有已安装的软件
```
scoop uninstall '*'
```

### 🗂️ 删除 Scoop 目录

找到 Scoop 安装目录（默认在 `C:\Users\你的用户名\scoop`），然后运行以下命令删除：
```powershell
Remove-Item -Recurse -Force "C:\Users\$env:UserName\scoop"
```

或者通过 `$env:SCOOP` 变量删除：
```powershell
Remove-Item -Recurse -Force $env:SCOOP
```

### 🛠️ 删除环境变量

在 PowerShell 中运行：
```powershell
[Environment]::SetEnvironmentVariable('SCOOP', $null, 'User')
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $null, 'Machine')
```

### 🗑️ 删除 Scoop 相关的 PATH 变量
```
[System.Environment]::SetEnvironmentVariable('Path', ($env:Path -replace "C:\\Users\\$env:UserName\\scoop\\shims;", ""), 'User')
```

### 🔄 重新启动计算机

执行完上述命令后，建议重启计算机以使更改生效。

🎉 以上就是 Scoop 的完整安装、卸载、目录更改、软件管理和备份恢复的详细指南，希望对你有所帮助！ 🚀