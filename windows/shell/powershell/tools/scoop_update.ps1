# scoop_update.ps1
param(
    [switch]$Commit = $true
)

# -----------------------------
# 配置变量
# -----------------------------
$projectDir = "E:\code\IdeaProjects\notebook"
$scoopFile = "windows\scoop\scoopfile.json"
$fullScoopFilePath = Join-Path $projectDir $scoopFile

# -----------------------------
# 更新 scoop 并导出文件
# -----------------------------
scoop update *
scoop cache rm *
scoop cleanup *
scoop export | Out-File -FilePath $fullScoopFilePath -Encoding utf8

# -----------------------------
# 进入项目目录
# -----------------------------
Set-Location $projectDir

# -----------------------------
# 判断是否需要提交
# -----------------------------
if ($Commit) {
    if (git status --porcelain $scoopFile) {
        $commitMsg = "update scoopfile.json: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git add $scoopFile
        git commit -m $commitMsg
        git push
        Write-Host "scoopfile.json 已提交并推送。"
    } else {
        Write-Host "scoopfile.json 无变化，跳过提交。"
    }
} else {
    Write-Host "自动提交被关闭，只导出文件，不提交。"
}
Start-Sleep -Seconds 6
