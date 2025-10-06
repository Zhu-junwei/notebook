@echo off & chcp 65001>nul

echo 读取注册表中的值 
:: 存在的项 
call :read_reg_value "HKEY_CURRENT_USER\Control Panel\Desktop" "Wallpaper"
if not defined ret_value (echo 未找到) else (echo 键值是: %ret_value%) 

:: 不存在的项 
call :read_reg_value "HKEY_CURRENT_USER\Control Panel\Desktop" "Wallpaper1234"
if not defined ret_value (echo 未找到) else ( echo 键值是: %ret_value% )

:: 不存在的路径 
call :read_reg_value "HKEY_CURRENT_USER\Control Panel\Desktop111" "Wallpaper"
if not defined ret_value (echo 未找到) else ( echo 键值是: %ret_value% )


pause

:read_reg_value
set "ret_value="
set "reg_cmd=reg query "%~1" /v "%~2" 2^>nul ^| findstr /I /C:"%~2""
for /f "tokens=1,2,*" %%G in ('%reg_cmd%') do (
	set "ret_value=%%I"
)
exit /b