@echo off & chcp 65001>nul
:: REG DELETE 删除整个注册表项（包括子项） 删除某个注册表值 
:: REG DELETE <注册表路径> [/v 值名 | /ve | /va] [/f] 
:: /v 值名	删除指定的键值 
:: /ve	删除 (默认) 值（键名为空的值） 
:: /va	删除该项下的所有值（不删除子项） 
:: /f	强制执行，不提示确认（Force） 
reg add "HKCR\DesktopBackground\Shell\hello" /v t1 /t REG_SZ /d world /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t2 /t REG_BINARY /d 01abef12 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t3 /t REG_DWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t4 /t REG_QWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t5 /t REG_MULTI_SZ /d file1.txt\0file2.txt\0file3.txt\0 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t6 /t REG_EXPAND_SZ /d "%%SystemRoot%%\MyApp" /f
reg add "HKCR\DesktopBackground\Shell\hello\sub" /v t1 /t REG_SZ /d sub_world /f

echo 按任意键删除添加的注册表 & pause>nul
:: 测试无法使用，提示 ERROR: The system was unable to find the specified registry key or value. 
:: reg delete "HKCR\DesktopBackground\Shell\hello" /ve /f
echo 删除hello项下的t1键 & pause>nul  
reg delete "HKCR\DesktopBackground\Shell\hello" /v t1 /f
echo 删除hello下的所有值（不删除子项） & pause>nul 
reg delete "HKCR\DesktopBackground\Shell\hello" /va /f
echo 删除hello项（包括子项） & pause>nul 
reg delete "HKCR\DesktopBackground\Shell\hello" /f
pause