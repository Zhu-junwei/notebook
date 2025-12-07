[PowerShell教程™ (yiibai.com)](https://www.yiibai.com/powershell)

# 修改执行策略

需要管理员身份运行。

```powershell
Set-ExecutionPolicy Unrestricted
```

运行hello world

```
echo "Hello world......"
```

# PowerShell注释

单行注释

> \# 这是单行注释

多行注释

> <# 这是多行注释 #>

```powershell
<# 打印1-10之间的偶数 #>

for ( $i = 1; $i -le 10; $i++ )
{
    $x = $i % 2
    if($x -eq 0)
    {
        echo $i
    }
}
```

# PowerShell的坏境定义

```
# 当前用户，PowerShell ISE
$profile
```

# 设置标题

```
$Host.UI.RawUI.WindowTitle = "测试"
$Host.UI.RawUI.WindowTitle = ""
```

# 适配器

```
# PSProvider用来访问不同类型数据的“适配器”或“接口”
Get-PSProvider
# 具体可访问的“根目录”入口，由 Provider 支持
Get-PSDrive
```

# 帮助

```
# 更新文档
Update-Help
# 命令行文档
Get-Help Get-Command
# 窗口文档
Get-Help Get-Command -ShowWindow
# 在线文档
Get-Help Get-Command -Online
# 获取模块的命令
Get-Command -Moudle 模块名
```

# 别名

```
# 查看别名
Get-Alias
# 设置别名
Set-Alias lsall Get-ChildItem
# 删除别名
Remove-Item Alias:lsall
```

# 模块

```
# 查看已安装模块
Get-InstalledModule
# 查看BurntToast模块的所有版本
Get-InstalledModule -Name BurntToast -AllVersions

# 查看当前已加载模块
Get-Module

# 查找
Find-Module "*wifi*"
Find-Module -Name "*wifi*"
Find-Module -Name 模块名

# 安装
Install-Module -Name 模块名
# 安装到当前用户，不需要管理员权限
Install-Module -Name 模块名 -Scope CurrentUser

# 更新某个模块
Update-Module -Name 模块名
# 更新所有模块
Update-Module -Force

# 卸载模块
Remove-Module -Name 模块名
Uninstall-Module -Name 模块名
Uninstall-Module -Name 模块名 -AllVersions
# 卸载旧的版本，管理员运行
Get-InstalledModule | ForEach-Object {
    $name = $_.Name
    $modules = Get-InstalledModule -Name $name -AllVersions | Sort-Object Version
    if ($modules.Count -gt 1) {
        $modules[0..($modules.Count-2)] | ForEach-Object {
            Uninstall-Module $_.Name -RequiredVersion $_.Version -Force
        }
    }
}
```

常用插件

```


```



# 对象属性

```
"" | Get-Member
Get-Process | Where-Object {$_.ProcessName -like '*navi*'}
Get-Process | select Processname
Get-Process | select Processname | Get-Member
```

创建自定义显示信息

```
@{Name="Property Name";Expression={}}

```

添加属性

```
Add-Member

Add-Member -InputObject <对象> -MemberType <类型> -Name <名称> -Value <值>
对象 | Add-Member -MemberType <类型> -Name <名称> -Value <值> -PassThru

Get-Process | Select-Object Name, Id | Add-Member -MemberType NoteProperty -Name "Tag" -Value "system" -PassThru
```

弹窗

```
$wsh=New-Object -com wscript.shell
$wsh.popup("hello")
```

# 逻辑运算

| 运算符    | 含义  | 说明                      | 示例                                |
| ------ | --- | ----------------------- | --------------------------------- |
| `-and` | 逻辑与 | 两个条件都为 True 才返回 True    | `(5 -gt 3) -and (2 -lt 4)` → True |
| `-or`  | 逻辑或 | 两个条件只要有一个 True 就返回 True | `(5 -gt 10) -or (2 -lt 4)` → True |
| `-not` | 逻辑非 | 取反条件                    | `-not (5 -eq 5)` → False          |


# 比较运算符


| 运算符         | 含义       | 说明                           | 示例                                 |
| -------------- | ---------- | ------------------------------ | ------------------------------------ |
| `-eq`          | 等于       | 比较数字或字符串是否相等       | `5 -eq 5` → True                     |
| `-ne`          | 不等于     | 比较数字或字符串是否不同       | `10 -ne 5` → True                    |
| `-lt`          | 小于       | 数值比较                       | `3 -lt 10` → True                    |
| `-le`          | 小于等于   | 数值比较                       | `10 -le 10` → True                   |
| `-gt`          | 大于       | 数值比较                       | `8 -gt 5` → True                     |
| `-ge`          | 大于等于   | 数值比较                       | `7 -ge 7` → True                     |
| `-like`        | 模糊匹配   | 使用通配符 `*` `?` 匹配字符串  | `"hello" -like "he*"` → True         |
| `-notlike`     | 模糊不匹配 | 当字符串不符合通配符匹配       | `"apple" -notlike "*banana*"` → True |
| `-match`       | 正则匹配   | 使用 Regex 表达式匹配字符串    | `"a123" -match "\d+"` → True         |
| `-notmatch`    | 正则不匹配 | 不符合正则表达式则为 True      | `"abc" -notmatch "\d"` → True        |
| `-contains`    | 包含       | 左边是集合，判断是否包含右边值 | `@(1,2,3) -contains 2` → True        |
| `-notcontains` | 不包含     | 集合中不存在某项               | `@(1,2,3) -notcontains 5` → True     |
| `-in`          | 属于       | 判断右边列表是否包含左边值     | `2 -in @(1,2,3)` → True              |
| `-notin`       | 不属于     | 判断是否不在列表中             | `5 -notin @(1,2,3)` → True           |

# 格式化输出

## Format-Table （默认表格形式）

**特点**：显示多条对象，每条对象一行，列对齐。  

**常用参数**：
- `-Property`：指定显示的属性
- `-AutoSize`：自动调整列宽
- `-Wrap`：换行显示太长内容

**示例**：
```powershell
Get-Process | Format-Table Name, Id, CPU -AutoSize
```

输出类似：

```
Name                     Id  CPU
----                     --  ---
powershell             1234 0.25
explorer               5678 12.5
```

##  Format-List （列表形式）

**特点**：每个对象占用多行显示，每行显示一个属性，适合显示属性很多的对象。

**常用参数**：

- `-Property`：选择显示的属性
- `*`：显示所有属性

**示例**：

```
Get-Process | Where-Object {$_.Name -like "fire*"} | Format-List *
```

输出类似：

```
Name        : firefox
Id          : 1234
CPU         : 34.5
WorkingSet  : 450000000
...
```

## Format-Wide （宽输出）

**特点**：仅显示单个属性，按控制台宽度排列，多列显示。

**常用参数**：

- `-Column`：指定列数

**示例**：

```
Get-Process | Format-Wide -Property Name -Column 3
```

输出类似：

```
powershell   explorer   firefox
svchost      notepad    chrome
```

# Select-Object

> `Select-Object` 用于从对象集合中选择特定的属性或创建新的自定义属性，常用于对管道传递的对象进行投影或简化输出。

基本语法

```powershell
Select-Object [-Property] <string[]> [-ExcludeProperty <string[]>] [-ExpandProperty <string>] [-Unique] [-First <int>] [-Last <int>] [-Skip <int>] [-InputObject <PSObject>] [<CommonParameters>]
```

示例
```
# 只显示进程名和进程ID
Get-Process | Select-Object Name, Id

# 将内存大小转换为MB并显示
Get-Process | Select-Object Name, @{Name='MemoryMB'; Expression={$_.PrivateMemorySize64 / 1MB}}

# 显示所有服务状态，但去重
Get-Service | Select-Object -Property Status -Unique

# 只输出进程名字符串，而不是对象
Get-Process | Select-Object -ExpandProperty Name

# 显示所有服务状态，但去重
Get-Service | Select-Object -Property Status -Unique

# 显示前5个进程
Get-Process | Select-Object -First 5

# 显示最后3个进程
Get-Process | Select-Object -Last 3

# 跳过前2个进程，显示剩余
Get-Process | Select-Object -Skip 2

# 显示进程对象，但不显示 Handles 和 Path 属性
Get-Process | Select-Object -ExcludeProperty Handles, Path

# 从变量对象中选择属性
$proc = Get-Process | Select-Object -First 1
Select-Object -InputObject $proc Name, Id

# 显示进程名和内存(MB)，并按内存排序
Get-Process | Select-Object Name, @{Name='MemoryMB'; Expression={$_.PrivateMemorySize64 / 1MB}} | Sort-Object MemoryMB -Descending
```

# Sort-Object

[Sort-Object](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-5.1&WT.mc_id=ps-gethelp)

# Group-Object

```
Get-ChildItem -Path $PSHOME -Recurse | Group-Object -Property Extension -NoElement | Sort-Object -Property Count -Descending
```
# Select-String

# 任务计划

相关命令

```
taskschd.msc
```

```
New-JobTrigger
New-ScheduledJobOption

Register-ScheduledJob
Unregister-ScheduledJob
Get-ScheduledJob
Disable-ScheduledJob
Enable-ScheduledJob

Add-JobTrigger
Set-JobTrigger
Set-ScheduledJob
Set-ScheduledJobOption
```

示例：

管理员运行

```
$trigger=New-JobTrigger -Daily -At "16:00"
$action={$dirpath="C:\test\"+(Get-Date).ToString("yyyyMMdd");New-Item -ItemType Directory $dirpath}
$options=New-ScheduledJobOption -RunElevated
Register-ScheduledJob -Name "dail" -Trigger $trigger -ScheduledJobOption $options -ScriptBlock $action

Get-JobTrigger -Name dail | Set-JobTrigger -Daily -At "17:00"
```

# 远程访问

```powershell

<#
开启远程功能（管理员运行）, 这会启动 WinRM 服务并允许远程管理。
WinRM 是全称是Windows Remote Management。他是微软的远程管理的全新组件，基于WinRM部署了WSMan的协议。他是基于SOAP的一个标准协议接口，可以实现操作系统，第三方系统等等实现我们的系统的操作与连接。
#>
Enable-PSRemoting -Force

#检查 WinRM 状态
Get-Service WinRM
Start-Service WinRM
# 设置开机自启
Set-Service -Name WinRM -StartupType Automatic

<#
PowerShell 远程执行（Invoke-Command）是基于 WinRM（Windows Remote Management） 的。
WinRM 默认使用 Kerberos 认证，这在非域环境或者使用 IP 地址访问远程电脑时会失败。
为了让 WinRM 接受非域、非 Kerberos 的远程连接，需要设置 TrustedHosts 列表。
#>
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.234.6" -Force
Get-Item WSMan:\localhost\Client\TrustedHosts
# 清空整个 TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "" -Force

# 远程用户凭证
$cred = Get-Credential
# 在远程执行命令，同一域可以不用Credential
Invoke-Command -ComputerName "192.168.234.6" -Credential $cred -ScriptBlock { ipconfig }
Invoke-Command -ComputerName "Server01" -Credential $cred -ScriptBlock { whoami }
Invoke-Command -session $sessionname -ScriptBlock { script code }

#建立会话
$session = New-PSSession -ComputerName "192.168.234.6"
$session = New-PSSession -ComputerName "192.168.234.6" -Credential $cred
# 查看会话
Get-PSSession
#进入会话
Enter-PSSession $session
#关闭会话
Remove-PSSession $session
```



**允许空密码远程访问（不推荐）**

- Windows 有一个策略可以允许空密码远程访问：

  1. 在远程机器上运行 `secpol.msc` → 本地策略 → 安全选项 → “账户：使用空密码的本地账户只允许控制台登录” → **禁用**

  2. 或者修改注册表：

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse
```

将值改为 `0`
```
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 0 /f
```

# Powershell Web Access

# 数据类型

| 数据类型              | 描述               | 示例代码                       | 示例结果            |
| --------------------- | ------------------ | ------------------------------ | ------------------- |
| `[string]`            | 字符串             | `"Hello"`                      | Hello               |
| `[char]`              | 单个字符           | `[char]'A'`                    | A                   |
| `[int] / [int32]`     | 32位整数           | `[int]123`                     | 123                 |
| `[long] / [int64]`    | 64位整数           | `[long]1234567890123`          | 1234567890123       |
| `[short] / [int16]`   | 16位整数           | `[short]32000`                 | 32000               |
| `[byte]`              | 0-255 的整数       | `[byte]255`                    | 255                 |
| `[sbyte]`             | -128 到 127 的整数 | `[sbyte]-10`                   | -10                 |
| `[uint] / [uint32]`   | 无符号 32位整数    | `[uint]123`                    | 123                 |
| `[ulong] / [uint64]`  | 无符号 64位整数    | `[ulong]1234567890123`         | 1234567890123       |
| `[ushort] / [uint16]` | 无符号 16位整数    | `[ushort]60000`                | 60000               |
| `[float] / [single]`  | 单精度浮点         | `[float]3.14`                  | 3.14                |
| `[double]`            | 双精度浮点         | `[double]3.1415926`            | 3.1415926           |
| `[decimal]`           | 高精度数值         | `[decimal]1.2345`              | 1.2345              |
| `[bool]`              | 布尔值             | `$true / $false`               | True / False        |
| `[datetime]`          | 日期时间           | `[datetime]"2025-11-27"`       | 2025/11/27 00:00:00 |
| `[timespan]`          | 时间间隔           | `[timespan]"12:30:00"`         | 12:30:00            |
| `[array]`             | 数组               | `@(1,2,3)`                     | {1,2,3}             |
| `[object[]]`          | 对象数组           | `[object[]](1,"a",3.14)`       | {1,"a",3.14}        |
| `[hashtable]`         | 键值对             | `@{Name='Tom'; Age=18}`        | Name=Tom; Age=18    |
| `[pscustomobject]`    | 自定义对象         | `[pscustomobject]@{a=1;b=2}`   | a=1; b=2            |
| `[regex]`             | 正则对象           | `[regex]"^\d+$"`               | 正则对象            |
| `[guid]`              | 全局唯一 ID        | `[guid]::NewGuid()`            | 生成 GUID           |
| `[scriptblock]`       | 可执行代码块       | `{ param($x) $x*2 }`           | 可执行块            |
| `[xml]`               | XML 文档对象       | `[xml]"<root><a>1</a></root>"` | XMLDocument         |
| `[version]`           | 程序/文件版本      | `[version]"1.0.0.0"`           | 1.0.0.0             |
| `[timespan]`          | 时间间隔           | `[timespan]"1.02:03:04"`       | 1.02:03:**04**      |

## 整数

```
$age = 18
```

## 小数

```
$price = 3.1415

# 保留两位 3.14
'{0:n2}' -f $price

# 百分比  314.5%
'{0:p2}' -f $price
```

## 字符

```
$str = "hello"
$str.length
$str.contains("h")
$str.replace("h","H")
# 去除前后空格
"  abc ".trim()
# 分割
"a:b::c".split(":")
$str.substring(0,3)
```

## 日期

```
Get-Date

$date=Get-Date
$date.ToString("yyyy-MM-dd HH:mm:ss")
Get-Date -Format "yyyy-MM-dd HH:mm:ss"
```



## 数组

```
创建数组
# 方法1：使用逗号分隔
$numbers = 1, 2, 3, 4, 5
# 方法2：使用 @() 语法
$names = @("Alice", "Bob", "Charlie")
# 空数组
$emptyArray = @()

# 访问数组元素
$numbers[0]   # 获取第一个元素，结果 1
$numbers[-1]  # 获取最后一个元素，结果 5
$numbers[0..2] # 获取前3个元素，结果 1 2 3

# 修改数组元素
$numbers[0] = 10   # 将第一个元素修改为 10
$numbers           # 输出: 10 2 3 4 5

# 添加元素
# 使用 +=
$numbers += 6
$numbers           # 输出: 10 2 3 4 5 6
# 插入到指定位置
$numbers = $numbers[0..2] + 99 + $numbers[3..($numbers.Length-1)]
# PowerShell 数组是固定长度的，+= 会创建一个新的数组，因此频繁添加元素性能不高。如果需要高效操作，可以用 ArrayList。
$list = New-Object System.Collections.ArrayList
$list.Add(1)
$list.Add(2)
$list

# 遍历数组
foreach ($item in $numbers) {
    Write-Output $item
}
$numbers | ForEach-Object { $_ * 2 }   # 每个元素乘2

# 数组操作示例
# 获取数组长度
$numbers.Length
$numbers | Sort-Object
$numbers | Where-Object { $_ -gt 3 }
```

