# 启用IP转发

打开 **PowerShell（以管理员身份）**，运行：

```powershell
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IPEnableRouter"
```

如果输出是：

```yaml
IPEnableRouter : 0
```

说明未启用；若要开启，请运行：

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IPEnableRouter" -Value 1
```

然后**重启电脑**使设置生效。