@echo off & chcp 65001>nul
:: REG EXPORT 导出注册表 
:: REG EXPORT <注册表项路径> <目标文件路径> [/y] 
:: 	<注册表项路径>	要导出的注册表项（如 HKCU\Software\MyApp） 
:: 	<目标文件路径>	要保存的 .reg 文件路径（如 C:\backup\myapp.reg） 
:: 	/y	（可选）自动覆盖目标文件（不提示） 
reg add "HKCR\DesktopBackground\Shell\hello" /v t1 /t REG_SZ /d world /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t2 /t REG_BINARY /d 01abef12 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t3 /t REG_DWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t4 /t REG_QWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t5 /t REG_MULTI_SZ /d file1.txt\0file2.txt\0file3.txt\0 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t6 /t REG_EXPAND_SZ /d "%%SystemRoot%%\MyApp" /f
reg add "HKCR\DesktopBackground\Shell\hello\sub" /v t1 /t REG_SZ /d sub_world /f

echo 按任意导出注册表 & pause>nul
reg export "HKCR\DesktopBackground\Shell\hello" "C:\hello.reg" /y

echo 按任意键删除添加的注册表 & pause>nul
reg delete "HKCR\DesktopBackground\Shell\hello" /f
pause