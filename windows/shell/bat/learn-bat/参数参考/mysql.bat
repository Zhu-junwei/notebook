@echo off 
call :sub tmp.txt 
pause & exit 
:sub 
echo 删除引号: %~1 
echo 扩充到路径: %~f1 
echo 扩充到一个驱动器号: %~d1 
echo 扩充到一个路径:%~p1 
echo 扩充到一个文件名: %~n1 
echo 扩充到一个文件扩展名: %~x1 
echo 扩充的路径只含有短名: %~s1 
echo 扩充到文件属性: %~a1 
echo 扩充到文件的日期/时间: %~t1 
echo 扩充到文件的大小: %~z1 
echo 查找列在PATH 环境变量的目录，并将第一个参数扩充到找到的第一个完全合格的名称。%~$PATH :1 
echo 扩展到驱动器号和路径: %~dp1 
echo 扩展到文件名和扩展名: %~nx1 
echo 扩展到类似DIR的输出行: %~ftza1 