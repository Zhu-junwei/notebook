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
        [int]$Width
    )

    $result = ''
    $current = 0

    foreach ($ch in $Text.ToCharArray()) {
        $w = if ($ch -match '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFF60]') { 2 } else { 1 }

        if ($current + $w -gt $Width) { break }

        $result += $ch
        $current += $w
    }

    return $result + (' ' * ($Width - $current))
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
        [ConsoleColor]$TextColor = $Global:UI.TextColor
    )

    $s = Get-BoxStyle
    $width = $Global:UI.Width

    # 左侧留 1 列空格
    $content = " $Text"

    $fitted = Fit-Text $content $width

    Write-Host $s.V -ForegroundColor $Global:UI.BorderColor -NoNewline
    Write-Host $fitted -ForegroundColor $TextColor -NoNewline
    Write-Host $s.V -ForegroundColor $Global:UI.BorderColor
}

# ==========================================================
# 菜单渲染
# ==========================================================
function Show-NssmMenu {
    Clear-Host
    Write-Host ""

    Write-BoxTop
    Write-BoxLine "NSSM 服务管理菜单" -TextColor $Global:UI.TitleColor
    Write-BoxSeparator

    Write-BoxLine "1. 服务列表"   -TextColor $Global:UI.AccentColor
    Write-BoxLine "2. 添加新服务"
    Write-BoxLine "3. About / 关于"
    Write-BoxLine ""
    Write-BoxLine "0. 退出" -TextColor $Global:UI.MutedColor

    Write-BoxBottom
    Write-Host ""
}

# ==========================================================
# 启动
# ==========================================================
Show-NssmMenu
Pause
