@echo off & chcp 65001>nul
:: 打印当前目录下的所有文件，不包括子目录  
for %%i in (*) do echo %%i 
echo ***************
:: 打印 a b c d e ,逗号空格分号都可以作为分隔符 
for %%i in (a, b c,d;e) do echo %%i
echo ***************
:: 打印字母表 
set var=a b c d e f g h i j k l m n o p q r s t u v w x y z 
for %%i in (%var%) do echo %%i   
pause