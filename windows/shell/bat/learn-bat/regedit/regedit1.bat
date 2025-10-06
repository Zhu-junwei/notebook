@echo off & chcp 65001>nul
:: 添加项 
reg add "HKCR\DesktopBackground\Shell\test" /f
:: 添加值，没有项的话会自动创建 
:: /v hello1 定义值的名字
:: /t REG_SZ 定义值的类型
:: 		REG_SZ 	字符串	/t REG_SZ /d "C:\MyApp\"
::		REG_BINARY 二进制数据 "/t REG_BINARY /d 01abef12"
::		REG_DWORD 32位整型 "/t REG_DWORD /d 1"
::		REG_QWORD 64位整型 "/t REG_DWORD /d 1"
::		REG_MULTI_SZ 多字符串,以 null (\0) 分隔	"REG_MULTI_SZ /d "file1.txt\0file2.txt\0file3.txt\0" "
::		REG_EXPAND_SZ 可扩充字符串,含有变量（如 %SystemRoot%）的字符串，会在使用时自动展开 "/t REG_EXPAND_SZ /d "%%SystemRoot%%\MyApp""
reg add "HKCR\DesktopBackground\Shell\hello" /v t1 /t REG_SZ /d world /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t2 /t REG_BINARY /d 01abef12 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t3 /t REG_DWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t4 /t REG_QWORD /d 1 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t5 /t REG_MULTI_SZ /d file1.txt\0file2.txt\0file3.txt\0 /f
reg add "HKCR\DesktopBackground\Shell\hello" /v t6 /t REG_EXPAND_SZ /d "%%SystemRoot%%\MyApp" /f
echo 按任意键删除添加的注册表 & pause>nul
reg delete "HKCR\DesktopBackground\Shell\test" /f
reg delete "HKCR\DesktopBackground\Shell\hello" /f
pause