<#
.SYNOPSIS
    基于 PowerShell 的控制台菜单 UI 渲染工具（支持中英文对齐、多种边框样式与主题）

.DESCRIPTION
    本脚本实现了一套可复用的控制台 UI 渲染组件，用于在 PowerShell
    环境中构建结构化、可读性良好的文本菜单界面。

    主要特性包括：
      - 正确处理中英文（CJK）字符显示宽度，保证边框与文本严格对齐
      - 支持多种边框风格（双线、单线、粗线、圆角、ASCII）
      - 边框颜色与文本颜色完全解耦，支持主题化配置
      - 支持文本左对齐 / 居中 / 右对齐
      - 所有布局与样式均通过集中配置控制，便于维护与扩展

.DESIGN NOTES
    - 本脚本未依赖任何第三方模块，兼容 Windows PowerShell 5.1 及 PowerShell 7+
    - 未使用字符串 Length / PadRight 进行布局，避免中英文宽度错误
    - 文本显示宽度基于 Unicode East Asian Width 特性进行估算
    - UI 逻辑（布局 / 对齐）与业务逻辑完全分离

.USAGE
    1. 修改 $Global:UI 中的配置项以调整宽度、颜色和边框风格
    2. 调用 Show-NssmMenu 或自定义菜单渲染函数
    3. 可按需扩展为多级菜单或拆分为 .psm1 模块

.AUTHOR
    <Your Name>

.VERSION
    1.0.0

.LICENSE
    Internal / Personal Use

#>

# ==========================================================
# UI 全局配置
# ==========================================================
$Global:UI = @{
    Width       = 34
    BorderColor = 'DarkCyan'
    TitleColor  = 'Cyan'
    TextColor   = 'White'
    MutedColor  = 'DarkGray'
    AccentColor = 'Cyan'

    BoxStyle    = 'Rounded'   # Double / Single / Heavy / Rounded / Ascii
}

# ==========================================================
# 边框样式定义
# ==========================================================
$Global:BoxStyles = @{
    Double = @{
        TL = '╔'; TR = '╗'; BL = '╚'; BR = '╝'
        H  = '═'; V  = '║'
        ML = '╠'; MR = '╣'
    }
    Single = @{
        TL = '┌'; TR = '┐'; BL = '└'; BR = '┘'
        H  = '─'; V  = '│'
        ML = '├'; MR = '┤'
    }
    Heavy = @{
        TL = '┏'; TR = '┓'; BL = '┗'; BR = '┛'
        H  = '━'; V  = '┃'
        ML = '┣'; MR = '┫'
    }
    Rounded = @{
        TL = '╭'; TR = '╮'; BL = '╰'; BR = '╯'
        H  = '─'; V  = '│'
        ML = '├'; MR = '┤'
    }
    Ascii = @{
        TL = '+'; TR = '+'; BL = '+'; BR = '+'
        H  = '-'; V  = '|'
        ML = '+'; MR = '+'
    }
}

enum TextAlign {
    Left
    Center
    Right
}

function Get-BoxStyle {
    $Global:BoxStyles[$Global:UI.BoxStyle]
}

# ==========================================================
# 【核心】计算字符串显示宽度（中英文对齐关键）
# ==========================================================
function Get-DisplayWidth {
    param([string]$Text)

    $width = 0
    foreach ($ch in $Text.ToCharArray()) {
        # CJK 统一表意字符 + 全角符号 → 宽度 2
        if ($ch -match '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFF60]') {
            $width += 2
        }
        else {
            $width += 1
        }
    }
    return $width
}

# ==========================================================
# 内容裁剪 + 填充（基于显示宽度）
# ==========================================================
function Fit-Text {
    param(
        [string]$Text,
        [int]$Width,
        [TextAlign]$Align = [TextAlign]::Left
    )

    # 先裁剪（防止溢出）
    $trimmed = ''
    $used = 0

    foreach ($ch in $Text.ToCharArray()) {
        $w = if ($ch -match '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFF60]') { 2 } else { 1 }
        if ($used + $w -gt $Width) { break }
        $trimmed += $ch
        $used += $w
    }

    $space = $Width - $used

    switch ($Align) {
        'Right' {
            return (' ' * $space) + $trimmed
        }
        'Center' {
            $left  = [Math]::Floor($space / 2)
            $right = $space - $left
            return (' ' * $left) + $trimmed + (' ' * $right)
        }
        default {
            return $trimmed + (' ' * $space)
        }
    }
}

# ==========================================================
# 边框绘制
# ==========================================================
function Write-BoxTop {
    $s = Get-BoxStyle
    Write-Host ("{0}{1}{2}" -f $s.TL, ($s.H * $Global:UI.Width), $s.TR) `
        -ForegroundColor $Global:UI.BorderColor
}

function Write-BoxSeparator {
    $s = Get-BoxStyle
    Write-Host ("{0}{1}{2}" -f $s.ML, ($s.H * $Global:UI.Width), $s.MR) `
        -ForegroundColor $Global:UI.BorderColor
}

function Write-BoxBottom {
    $s = Get-BoxStyle
    Write-Host ("{0}{1}{2}" -f $s.BL, ($s.H * $Global:UI.Width), $s.BR) `
        -ForegroundColor $Global:UI.BorderColor
}

# ==========================================================
# 内容行（边框颜色 / 字体颜色完全分离）
# ==========================================================
function Write-BoxLine {
    param(
        [string]$Text = '',
        [ConsoleColor]$TextColor = $Global:UI.TextColor,
        [TextAlign]$Align = [TextAlign]::Left
    )

    $s = Get-BoxStyle
    $width = $Global:UI.Width

    # 左侧预留 1 列
    $content = " $Text"

    $aligned = Fit-Text $content $width $Align

    Write-Host $s.V -ForegroundColor $Global:UI.BorderColor -NoNewline
    Write-Host $aligned -ForegroundColor $TextColor -NoNewline
    Write-Host $s.V -ForegroundColor $Global:UI.BorderColor
}

# ==========================================================
# 菜单渲染
# ==========================================================
function Show-NssmMenu {
    Clear-Host
    Write-Host ""
    Write-BoxTop
    Write-BoxLine "NSSM 服务管理菜单" -TextColor $Global:UI.TitleColor -Align Center
    Write-BoxSeparator
    Write-BoxLine "1. 服务列表"   -TextColor $Global:UI.AccentColor
    Write-BoxLine "2. 添加新服务"
    Write-BoxLine "3. About / 关于"
    Write-BoxLine ""
    Write-BoxLine "0. 退出" -TextColor $Global:UI.MutedColor
	Write-BoxLine ""
	Write-BoxLine "v1.2.0  " -Align Right -TextColor $Global:UI.MutedColor
    Write-BoxBottom
    Write-Host ""
}

# ==========================================================
# 启动
# ==========================================================
Show-NssmMenu
Pause
