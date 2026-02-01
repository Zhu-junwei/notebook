# 点源加载脚本，导入函数和全局变量
. ".\Box.ps1"

# 调用函数
$items = @(
    @{ Text = '1. 启动服务'; Color = 'Green' },
    @{ Text = '2. 停止服务'; Color = 'Red' },
	@{ Text = '3. 退出'}
)
Show-BoxMenu -Title '测试菜单' -MenuItems $items -Footer '请选择操作'

$items = @(
    @{ Text = '新建项目'; Color = 'Cyan'; Align = 'Center' },
    @{ Text = '打开项目'; Color = 'Magenta'; Align = 'Center' },
    @{ Text = '关闭项目'; Color = 'Yellow'; Align = 'Center' }
)

Show-BoxMenu -Title '演示菜单居中' -MenuItems $items -Footer '按数字选择操作' -TitleAlign Center -FooterAlign Right

$items = @(
    @{ Text = '1. 这是一个很长的菜单项，需要在控制台自动换行显示1. 这是一个很长的菜单项，需要在控制台自动换行显示1. 这是一个很长的菜单项，需要在控制台自动换行显示1. 这是一个很长的菜单项，需要在控制台自动换行显示'; Color = 'Green' },
    @{ Text = '2. 这是第二项，也比较长，演示换行效果'; Color = 'Yellow' }
)

Show-BoxMenu -Title '演示换行' -MenuItems $items -Footer 'End of Menu' -Wrap


$items = @(
    @{ Text = '启动服务'; Color = 'Green' },
    @{ Text = '停止服务'; Color = 'Red' },
    @{ Text = '重启服务'; Color = 'Yellow' }
)
Show-BoxMenu -Title '边框样式演示' -MenuItems $items -Footer '请选择操作' -BoxStyle Double

$items = @(
    $null, # 空行
    @{ Text = '1. 安装依赖'; Color = $Global:UI.AccentColor },
    @{ Text = '2. 更新系统' },
    $null,
    @{ Text = '0. 退出'; Color = $Global:UI.MutedColor }
)

Show-BoxMenu -Title '空行演示' -MenuItems $items -Footer '请选择操作'

$items = @(
    @{ Text = '1. 不显示Title'; Color = $Global:UI.AccentColor },
    @{ Text = '2. 更新系统' },
    @{ Text = '0. 退出'; Color = $Global:UI.MutedColor }
)

Show-BoxMenu -MenuItems $items -Footer '请选择操作'


# 设置菜单宽度为 30
$Global:UI.Width = 30
$items = @(
    @{ Text = '1. 启动服务'; Color = 'Green' },
    @{ Text = '2. 停止服务'; Color = 'Red' },
    @{ Text = '3. 查看状态'; Color = 'Yellow' }
)

Show-BoxMenu -Title '小宽度菜单' -MenuItems $items -Footer '请选择操作'

Read-Host