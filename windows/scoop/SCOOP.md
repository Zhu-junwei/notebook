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

例如，如果希望 Scoop 安装到 `D:\scoop`，可以在 PowerShell 中运行：
```powershell
$env:SCOOP='D:\scoop'
[Environment]::SetEnvironmentVariable('USERSCOOP', $env:SCOOP, 'User')

这个需要管理员权限
$env:SCOOP_GLOBAL='D:\scoop'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
```

然后重新运行 Scoop 安装命令：
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

## 安装 🛠️ 和卸载 ❌ 软件

### 📦 搜索软件

可以使用 `Scoop` 搜索软件，例如搜索 `7zip`：
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

## bucket管理

>  bucket 是 Scoop 的一个概念，它允许用户添加额外的软件源，以便在 Scoop 中安装更多软件。

```powershell
# 列出已安装的 bucket
scoop bucket list
# 列出已知的 bucket
scoop bucket known
# 添加新的 bucket
scoop bucket add java
# 添加第三方的 bucket
scoop bucket add dorado https://github.com/chawyehsu/dorado 
```

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

### 🛠️ 删除环境变量

在 PowerShell 中运行：
```powershell
[System.Environment]::SetEnvironmentVariable('SCOOP', $null, 'User')
```

### 🗑️ 删除 Scoop 相关的 PATH 变量
```
[System.Environment]::SetEnvironmentVariable('Path', ($env:Path -replace "C:\\Users\\$env:UserName\\scoop\\shims;", ""), 'User')
```

### 🔄 重新启动计算机

执行完上述命令后，建议重启计算机以使更改生效。

🎉 以上就是 Scoop 的完整安装、卸载、目录更改、软件管理和备份恢复的详细指南，希望对你有所帮助！ 🚀