@echo off & chcp 65001>nul
:: REG QUERY 查看注册表项或键值 
:: REG QUERY <KeyName> [/v ValueName | /ve | /s | /se Separator | /f Data [/k] [/d] [/t Type] [/c] [/e]] 
:: <KeyName>	要查询的注册表完整路径（如：HKCU\Software\MyApp） 
:: /v <值名>	查询指定值名的数据 
:: /ve	查询“默认值”（无名称的值） 
:: /s	递归查询该项及所有子项 
:: /f <数据>	查询匹配指定数据的项或值 
:: /k	查找匹配项的值名（key） 
:: /d	查找匹配项的数据（data） 
:: /t <类型>	指定值类型，如：REG_SZ, REG_DWORD 
:: /c	区分大小写匹配 
:: /e	完整匹配值（exact match） 
:: /se	设置输出字段分隔符（默认是 TAB） 

reg add "HKCR\DesktopBackground\Shell\hello" /v t1 /t REG_SZ /d world /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t2 /t REG_BINARY /d 01abef12 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t3 /t REG_DWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t4 /t REG_QWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t5 /t REG_MULTI_SZ /d file1.txt\0file2.txt\0file3.txt\0 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t6 /t REG_EXPAND_SZ /d "%%SystemRoot%%\MyApp" /f
reg add "HKCR\DesktopBackground\Shell\hello\sub" /v t1 /t REG_SZ /d sub_world /f

echo 查询某注册表项的所有值 
reg query "HKCR\DesktopBackground\Shell\hello"
echo 递归查询该项及所有子项 
reg query "HKCR\DesktopBackground\Shell\hello" /s
echo.&echo.&echo 查询某注册表项的指定的值名 
reg query "HKCR\DesktopBackground\Shell\hello" /v t1 
echo.&echo.&echo 查询指定的类型 
reg query "HKCR\DesktopBackground\Shell\hello" /t REG_DWORD

echo 按任意键删除添加的注册表 & pause>nul
reg delete "HKCR\DesktopBackground\Shell\hello" /f
pause