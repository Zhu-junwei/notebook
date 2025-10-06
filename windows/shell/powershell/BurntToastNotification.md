[BurntToast/Help/New-BurntToastNotification.md 在主 ·温多斯/BurntToast --- BurntToast/Help/New-BurntToastNotification.md at main · Windos/BurntToast](https://github.com/Windos/BurntToast/blob/main/Help/New-BurntToastNotification.md)

```
Install-Module -Name BurntToast -Force -Scope CurrentUser
Import-Module BurntToast
New-BurntToastNotification -Text "欢迎使用", "这是一个右下角提示通知"
```

设置图标

```
New-BurntToastNotification -Text "通知标题", "这是正文内容" ` -AppLogo "C:\Path\To\your-logo.png"
```

