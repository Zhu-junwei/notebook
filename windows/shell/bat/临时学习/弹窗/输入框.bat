@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

for /f "usebackq delims=" %%i in (`
    powershell -NoProfile -WindowStyle Hidden -Command ^
    "Add-Type -AssemblyName System.Windows.Forms;" ^
    "$f = New-Object System.Windows.Forms.Form;" ^
    "$f.Text = '输入框';" ^
    "$f.Width = 300; $f.Height = 130;" ^
    "$tb = New-Object System.Windows.Forms.TextBox;" ^
    "$tb.Width = 200;" ^
    "$tb.Location = '50,10';" ^
    "$f.Controls.Add($tb);" ^
    "$panel = New-Object System.Windows.Forms.TableLayoutPanel;" ^
    "$panel.Dock = 'Bottom';" ^
    "$panel.Height = 35;" ^
    "$panel.ColumnCount = 4;" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)));" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)));" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)));" ^
    "$panel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)));" ^
    "$ok = New-Object System.Windows.Forms.Button;" ^
    "$ok.Text = '确定';" ^
    "$ok.Width = 80;" ^
    "$ok.Add_Click({ $f.Tag = 'OK'; $f.Close() });" ^
    "$cancel = New-Object System.Windows.Forms.Button;" ^
    "$cancel.Text = '取消';" ^
    "$cancel.Width = 80;" ^
    "$cancel.Add_Click({ $f.Tag = 'Cancel'; $f.Close() });" ^
    "$panel.Controls.Add($ok, 1, 0);" ^
    "$panel.Controls.Add($cancel, 2, 0);" ^
    "$f.Controls.Add($panel);" ^
    "$f.ShowDialog() | Out-Null;" ^
    "if ($f.Tag -eq 'OK') { Write-Output $tb.Text } else { Write-Output '__CANCEL__' }"
`) do set "userInput=%%i"

if "!userInput!"=="__CANCEL__" (
    echo 你点击了取消。
) else (
    echo 你输入的是：!userInput!
)

pause