@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

for /f "usebackq delims=" %%i in (`
    powershell -NoProfile -WindowStyle Hidden -Command ^
    "Add-Type -AssemblyName System.Windows.Forms;" ^
    "$f = New-Object System.Windows.Forms.Form;" ^
    "$f.Text = '选择重复时间'; $f.Width = 300; $f.Height = 150;" ^
    "$combo = New-Object System.Windows.Forms.ComboBox;" ^
    "$combo.Width = 200; $combo.Location = '50,10'; $combo.DropDownStyle = 'DropDownList';" ^
    "$options = [ordered]@{ ' 1 分钟'='PT1M'; ' 5 分钟'='PT5M'; '10 分钟'='PT10M'; '15 分钟'='PT15M'; '30 分钟'='PT30M';"^ 
	"' 1 小时'='PT1H'; ' 3 小时'='PT3H'; ' 6 小时'='PT6H'; '12 小时'='PT12H'; '24 小时'='PT24H' };" ^
    "$combo.Items.AddRange($options.Keys);" ^
    "$combo.SelectedIndex = 0;" ^
    "$f.Controls.Add($combo);" ^
    "$panel = New-Object System.Windows.Forms.TableLayoutPanel;" ^
    "$panel.Dock = 'Bottom'; $panel.Height = 35; $panel.ColumnCount = 4;" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 50)));" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('AutoSize')));" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('AutoSize')));" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 50)));" ^
    "$ok = New-Object System.Windows.Forms.Button;" ^
    "$ok.Text = '确定'; $ok.Width = 80;" ^
    "$ok.Add_Click({ $f.Tag = 'OK'; $f.Close() });" ^
    "$cancel = New-Object System.Windows.Forms.Button;" ^
    "$cancel.Text = '取消'; $cancel.Width = 80;" ^
    "$cancel.Add_Click({ $f.Tag = 'Cancel'; $f.Close() });" ^
    "$panel.Controls.Add($ok, 1, 0);" ^
    "$panel.Controls.Add($cancel, 2, 0);" ^
    "$f.Controls.Add($panel);" ^
    "$f.ShowDialog() | Out-Null;" ^
    "if ($f.Tag -eq 'OK') { $sel = $combo.SelectedItem; Write-Output $options[$sel] } else { Write-Output '__CANCEL__' }"
`) do set "isoResult=%%i"


if "!isoResult!"=="__CANCEL__" (
    echo 你点击了取消。 
) else (
    echo 你选择的 RepetitionInterval 是: !isoResult!
    REM 这里你可以直接用 !isoResult! 生成任务计划 
)

pause
