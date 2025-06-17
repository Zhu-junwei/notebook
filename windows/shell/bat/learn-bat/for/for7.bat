@echo off & chcp 65001>nul
:: eol 指定某个字符作为注释行的起始符号，被该字符开头的行会被 for 循环跳过，不会被处理。 
::  默认使用;作为注释行的起始符号 
for /f "usebackq eol=# delims=" %%i in ("%SystemRoot%\System32\drivers\etc\hosts") do (
    echo %%i
)

pause