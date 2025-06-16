@echo off
chcp 65001>nul
setlocal enabledelayedexpansion

:deepseek_chat
set /p "content=请输入(输入q退出): "
if "%content%"=="q" exit /b

curl.exe -v https://api.deepseek.com/chat/completions ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer sk-3a38003ce8a04122b52aa7aaae1fd443" ^
  -d "{^
    \"model\": \"deepseek-chat\",^
    \"messages\": [^
      {\"role\": \"system\", \"content\": \"You are a helpful assistant.\"},^
      {\"role\": \"user\", \"content\": \"%content%\"}^
    ],^
    \"stream\": false^
  }"

goto :deepseek_chat