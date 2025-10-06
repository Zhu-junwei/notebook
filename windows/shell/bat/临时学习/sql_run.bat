@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

:main
:: 输入数据库用户名，默认 root
set /p "user=请输入用户名(默认root):"
if "%user%"=="" set user=root
set /p "MYSQL_PWD=请输入密码(默认123456):"
if "%MYSQL_PWD%"=="" set MYSQL_PWD=123456
call :choose_db
if not "%db%"=="" call :exec_sql
exit

:: 选择数据库名
:choose_db
set "db="
set /p "db=请输入数据库名(为空进行命令行):"
if "%db%"=="" (
	mysql -u%user%
)
exit /b

:exec_sql
set "sql="
set /p sql=请输入SQL语句:
if "%sql%"=="m" cls & goto :main
if "%sql%"=="exit" exit /b
:: 调用mysql执行SQL
mysql -u%user% -D %db%  -e "%sql%"
goto :exec_sql