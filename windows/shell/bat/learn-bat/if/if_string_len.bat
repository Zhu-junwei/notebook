@echo off   
set num=0 
set /p str=请输入任意长度的字符串:  
if not defined str ( 
echo 您没有输入任何内容 
pause>nul & exit 
)  
:len   
set /a num+=1 
set str=%str:~0,-1% 
if defined str goto len 
echo 字符串长度为：%num%  
pause>nul