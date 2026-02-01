

# ==========================================================
# UI 全局配置
# ==========================================================
$Global:UI = @{
    Width       = 50
    BorderColor = 'DarkCyan'
    TitleColor  = 'Cyan'
    TextColor   = 'White'
	TextPaddingLeft = 2
    MutedColor  = 'DarkGray'
    AccentColor = 'Cyan'
    BoxStyle    = 'Rounded'   # Double / Single / Heavy / Rounded / Ascii
}

# ==========================================================
# 边框样式定义
# ==========================================================
$Global:BoxStyles = @{
    Double   = @{TL = '╔'; TR = '╗'; BL = '╚'; BR = '╝'; H  = '═'; V  = '║'; ML = '╠'; MR = '╣'}
    Single   = @{TL = '┌'; TR = '┐'; BL = '└'; BR = '┘'; H  = '─'; V  = '│'; ML = '├'; MR = '┤'}
    Heavy    = @{TL = '┏'; TR = '┓'; BL = '┗'; BR = '┛'; H  = '━'; V  = '┃'; ML = '┣'; MR = '┫'}
    Rounded  = @{TL = '╭'; TR = '╮'; BL = '╰'; BR = '╯'; H  = '─'; V  = '│'; ML = '├'; MR = '┤'}
    Ascii    = @{TL = '+'; TR = '+'; BL = '+'; BR = '+'; H  = '-'; V  = '|';ML = '+'; MR = '+'}
}

# ==========================================================
# 对齐方式
# ==========================================================
enum TextAlign { Left; Center; Right }

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
        [TextAlign]$Align = [TextAlign]::Left,
        [switch]$Wrap
    )

    $lines = @()
    $padding = if ($Global:UI.TextPaddingLeft) { $Global:UI.TextPaddingLeft } else { 0 }
    $usableWidth = $Width - $padding * 2
    $remaining = $Text

    while ($remaining) {
        $trimmed = ''
        $used = 0

        foreach ($ch in $remaining.ToCharArray()) {
            $w = if ($ch -match '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFF60]') { 2 } else { 1 }
            if ($used + $w -gt $usableWidth) { break }
            $trimmed += $ch
            $used += $w
        }

        # 不换行时超过宽度用 '..'
        if (-not $Wrap -and $remaining.Length -gt $trimmed.Length) {
            $finalTrim = ''
            $trimmedLength = 0
            foreach ($ch in $remaining.ToCharArray()) {
                $w = if ($ch -match '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFF60]') { 2 } else { 1 }
                if ($trimmedLength + $w -gt ($usableWidth - 2)) { break }
                $finalTrim += $ch
                $trimmedLength += $w
            }
            $trimmed = $finalTrim + '..'
            $used = $usableWidth
            $remaining = ''
        } else {
            $remaining = $remaining.Substring($trimmed.Length)
        }

        $space = $usableWidth - $used
        switch ($Align) {
            'Right'  { $line = (' ' * $space) + $trimmed }
            'Center' { $line = (' ' * [Math]::Floor($space/2)) + $trimmed + (' ' * ([Math]::Ceiling($space/2))) }
            default  { $line = $trimmed + (' ' * $space) }
        }
        $lines += (' ' * $padding) + $line + (' ' * $padding)
        if (-not $Wrap) { break }
    }

    return $lines
}

# ==========================================================
# 边框绘制
# ==========================================================
function Write-BoxBorder {
    param([ValidateSet('Top','Sep','Bottom')]$Type)

    $s = Get-BoxStyle
    $c = $Global:UI.BorderColor
    $w = $Global:UI.Width

    $line = switch ($Type) {
        'Top'    { "{0}{1}{2}" -f $s.TL, ($s.H * $w), $s.TR }
        'Sep'    { "{0}{1}{2}" -f $s.ML, ($s.H * $w), $s.MR }
        'Bottom' { "{0}{1}{2}" -f $s.BL, ($s.H * $w), $s.BR }
    }
    Write-Host $line -ForegroundColor $c
}

# ==========================================================
# 内容行（边框颜色 / 字体颜色完全分离）
# ==========================================================
function Write-BoxLine {
    param(
        [string]$Text = '',
        [ConsoleColor]$TextColor = $Global:UI.TextColor,
        [TextAlign]$Align = [TextAlign]::Left,
        [switch]$Wrap
    )

    $s = Get-BoxStyle
    $width = $Global:UI.Width
    $lines = Fit-Text $Text $width $Align -Wrap:$Wrap

    foreach ($line in $lines) {
        Write-Host $s.V -ForegroundColor $Global:UI.BorderColor -NoNewline
        Write-Host $line -ForegroundColor $TextColor -NoNewline
        Write-Host $s.V -ForegroundColor $Global:UI.BorderColor
    }
}

# ==========================================================
# 菜单渲染
# ==========================================================
function Show-BoxMenu {
    param(
        [string]$Title = '',
        [array]$MenuItems = @(),
        [string]$Footer = '',
        [TextAlign]$TitleAlign = [TextAlign]::Center,
        [TextAlign]$FooterAlign = [TextAlign]::Right,
        [string]$BoxStyle = $Global:UI.BoxStyle,
		[switch]$Wrap 
    )
    $Global:UI.BoxStyle = $BoxStyle
    Write-Host ""
    Write-BoxBorder Top
    if ($Title) {
        Write-BoxLine $Title -TextColor $Global:UI.TitleColor -Align $TitleAlign
        Write-BoxBorder Sep
    }
    foreach ($item in $MenuItems) {
		if ($item -and $item.Text) {
			$color = if ($item.Color) { $item.Color } else { $Global:UI.TextColor }
			$align = if ($item.Align) { $item.Align } else { [TextAlign]::Left }
			Write-BoxLine $item.Text -TextColor $color -Align $align -Wrap:$Wrap
		} else {
			Write-BoxLine ""
		}
	}
    if ($Footer) {
        Write-BoxLine "" # 空行分隔
        Write-BoxLine $Footer -TextColor $Global:UI.MutedColor -Align $FooterAlign
    }
    Write-BoxBorder Bottom
    Write-Host ""
}

function Show-Menu1 {
	$menuItems = @(
		@{Text='1. 服务列表'; Color=$Global:UI.AccentColor; Align='Left'},
		@{Text='2. 添加新服务'; Color=$Global:UI.TextColor; Align='Left'},
		@{Text='3. About / 关于'; Color=$Global:UI.TextColor; Align='Left'},
		@{Text='0. 退出'; Color=$Global:UI.MutedColor; Align='Left'}
	)
	Show-BoxMenu -Title "NSSM 服务管理菜单" -MenuItems $menuItems -Footer "v1.2.0 "
}

function Show-Menu2 {
	$menuItems = @(
		@{Text='1. 服务列表 - 这是一个非常长的描述，用于测试自动换行效果12344'},
		@{Text='2. 添加新服务 - 再加上一些额外说明文字，让它超过边框宽度'; Align='Left'},
		$null,
		@{Text='0. 退出'; Color=$Global:UI.MutedColor; Align='Left'}
	)
	Show-BoxMenu -MenuItems $menuItems -BoxStyle 'Double'
	Write-BoxLine "换行文本12333333333124141414444再加上一些额外说明文字，些额外说明文字，些额外说明文字，些额外说明文字，些额外说明文字，些额外说明文字，让它些额外说明文字，些额外说明文字，些额外说明文字，些额外说明文字，些额外说明文字，些额外说明文字，超过边框宽度" -Wrap 
}

Show-Menu1
Show-Menu2
Pause
