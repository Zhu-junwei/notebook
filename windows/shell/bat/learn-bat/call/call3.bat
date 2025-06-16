@echo off &chcp 65001>nul
title 参数增强 
call :sub tmp.txt 
call :sub D:\tmp.txt
pause & exit 
:sub 
:: 删除引号: tmp.txt
echo 删除引号: %~1 
:: 扩充到路径: E:\code\IdeaProjects\notebook\windows\shell\bat\learn-bat\call\tmp.txt
echo 扩充到路径: %~f1 
:: 扩充到一个驱动器号: E:
echo 扩充到一个驱动器号: %~d1 
:: 扩充到一个路径:\code\IdeaProjects\notebook\windows\shell\bat\learn-bat\call\
echo 扩充到一个路径:%~p1 
:: 扩展到驱动器号和路径: E:\code\IdeaProjects\notebook\windows\shell\bat\learn-bat\call\
echo 扩展到驱动器号和路径: %~dp1 
:: 扩充到一个文件名: tmp
echo 扩充到一个文件名: %~n1 
:: 扩充到一个文件扩展名: .txt
echo 扩充到一个文件扩展名: %~x1 
:: 扩展到文件名和扩展名: tmp.txt
echo 扩展到文件名和扩展名: %~nx1 
:: 扩充的路径只含有短名: E:\code\IDEAPR~1\notebook\windows\shell\bat\LEARN-~1\call\tmp.txt
echo 扩充的路径只含有短名: %~s1 
:: 扩充到文件属性: --a--------
echo 扩充到文件属性: %~a1 
:: 扩充到文件的日期/时间: 2025/06/14 15:46
echo 扩充到文件的日期/时间: %~t1 
:: 扩充到文件的大小: 24
echo 扩充到文件的大小: %~z1 
echo 查找列在PATH 环境变量的目录，并将第一个参数扩充到找到的第一个完全合格的名称。%~$PATH :1 
:: 扩展到类似DIR的输出行: --a-------- 2025/06/14 15:46 24 E:\code\IdeaProjects\notebook\windows\shell\bat\learn-bat\call\tmp.txt
echo 扩展到类似DIR的输出行: %~ftza1
echo =====================================================
exit /b

pause