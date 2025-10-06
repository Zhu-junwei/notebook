@echo off & chcp 65001>nul
:: REG import 导入注册表  
:: REG IMPORT <文件路径> 
:: <文件路径>	你要导入的 .reg 文件的完整路径，比如 C:\Backup\MyApp.reg 

reg import "C:\hello.reg"
echo 注册表已导入 

echo 按任意键删除添加的注册表 & pause>nul
reg delete "HKCR\DesktopBackground\Shell\hello" /f
pause