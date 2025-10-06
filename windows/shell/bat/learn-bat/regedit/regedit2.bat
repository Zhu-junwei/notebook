@echo off & chcp 65001>nul
:: 复制项 
:: reg copy <来源项路径> <目标项路径> [/s] [/f]
:: <来源项路径>：你要复制的项 
:: <目标项路径>：你要复制到的位置 
:: /s：复制子项（递归复制） 
:: /f：强制覆盖目标项中的现有项和值（无确认） 
reg add "HKCR\DesktopBackground\Shell\hello" /v t1 /t REG_SZ /d world /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t2 /t REG_BINARY /d 01abef12 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t3 /t REG_DWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t4 /t REG_QWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t5 /t REG_MULTI_SZ /d file1.txt\0file2.txt\0file3.txt\0 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t6 /t REG_EXPAND_SZ /d "%%SystemRoot%%\MyApp" /f
:: hello复制到hello2中 
reg copy "HKCR\DesktopBackground\Shell\hello" "HKCR\DesktopBackground\Shell\hello2" /s /f
echo 按任意键删除添加的注册表 & pause>nul
reg delete "HKCR\DesktopBackground\Shell\hello" /f
reg delete "HKCR\DesktopBackground\Shell\hello2" /f
pause