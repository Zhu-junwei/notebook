:daying
CLS
@echo off

echo.&echo.&echo.
echo          
echo.&echo.                
echo              本程序快速清除无响应的打印任务，解决无法打印的问题！ 
echo.
echo              对于网络共享打印机，请在连接打印机的电脑上运行程序！
echo.&echo. 
echo      ----------------------------------------------------------------    
echo                
echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo                 按下键盘任意键开始，退出请直接关闭！！
pause>nul 2>nul
cls
net session /delete /y>nul 2>nul
sc config spooler start= disabled>nul 2>nul
net stop spooler>nul 2>nul
attrib %systemroot%\System32\spool\PRINTERS\*.* -R /s>nul 2>nul
del %systemroot%\System32\spool\PRINTERS\*.* /q /s>nul 2>nul
sc config spooler start= auto>nul 2>nul
net start spooler>nul 2>nul
echo msgbox "清除完毕，请重新打印",,"提示" >%temp%\404.vbs
start /w %temp%\404.vbs
del /q %temp%\404.vbs
GOTO menu
