# 递归函数来生成目录结构
function Get-Tree {
    param (
        [string]$Path,
        [string]$Prefix = ""
    )

    $items = Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -notin @('scripts', '00_练习', '.git', '.idea', 'tree.txt', 'target') }

    $items | ForEach-Object {
        $isLast = $_ -eq $items[-1]
        $connector = if ($isLast) { "└── " } else { "├── " }
        $subPrefix = if ($isLast) { "    " } else { "│   " }

        "$Prefix$connector$($_.Name)"
        if ($_.PSIsContainer) {
            Get-Tree -Path $_.FullName -Prefix "$Prefix$subPrefix"
        }
    }
}

# 生成并保存目录结构
Get-Tree -Path "." | Out-File "tree.txt"
Write-Output "Directory structure saved to tree.txt"