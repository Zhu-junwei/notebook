@echo off & chcp 65001>nul

for /l %%i in (1,1,5) do (
    if %%i gtr 3 (
            echo %%i
        )
    )
)
echo 结束了 
pause