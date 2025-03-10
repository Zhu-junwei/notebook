@echo off 
title 圆周率计算程序 
echo 按任意键开始计算 & pause>nul 
echo 计算进行中，进度请看标题栏... 
set i=0 
:loop 
if %i% lss 10000 ( 
set /a i+=1 
title 圆周率计算程序 当前计算到第%i%位 
::这里是为了更明显点看到显示的效果，所以添加一个时间延迟。 
ping /n 1 127.1>nul 
goto :loop 
) 
Pause 