@echo off

rem 比较 "Hello" 和 "Hello"（完全匹配）
if "Hello" == "Hello" (
    echo 相等
) else (
    echo 不相等
)

rem 比较 "hello" 和 "Hello"（区分大小写）
if "hello" == "Hello" (
    echo 相等
) else (
    echo 不相等
)

rem 比较 "hello" 和 "Hello"（忽略大小写）
if /i "hello" == "Hello" (
    echo 相等
) else (
    echo 不相等
)


:byebye
echo See you.
ping -n 2 127.0.0.1>nul
pause