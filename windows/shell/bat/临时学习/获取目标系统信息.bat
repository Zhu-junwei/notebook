@echo off
if /i "%UserName%" == "SYSTEM" (Goto GotAdmin) else (reg query "HKLM\SYSTEM\ControlSet001\Control\MiniNT" 1>nul 2>nul&&Goto GotAdmin)
:BatchGotAdmin
Set _Args=%*
if `%1` neq `` Set "_Args=%_Args:"=""%"
if exist %WinDir%\System32\fltMC.exe fltMC 1>nul 2>nul||mshta VBScript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c """"%~f0"" %_Args%""",,"runas",1)(Window.Close) 2>nul&&Exit /b

:GotAdmin
Pushd "%CD%"&cd /d "%~dp0"
Title 获取目标系统信息&(if exist %WinDir%\System32\ureg.dll Mode 43,9 2>nul)&Color 2f
Set "filter=有效网卡" :: 默认只获取有效网卡信息

:SelectOS
Setlocal EnableDelayedExpansion
if `%1` neq `` Set "Input=%~1"&Goto Start
Set n=0&for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%~i:\Windows\System32\Config\SOFTWARE" if exist "%%~i:\Windows\System32\Config\SYSTEM" Set /a n+=1&Set dsk!n!=%%i&Set /a n+=1&Set dsk!n!=%%i
Set /a n=!n!/2
if !n! equ 1 Set Input=!dsk1!&Goto Start
if !n! geq 2 Set /a l=9+!n!*2&(if exist %WinDir%\System32\ureg.dll Mode 43,!l! 2>nul)&Color 2f
Call :EchoX "e0.: 选择您要获取信息的目标系统↓"
echo __________________________________________
Call :EchoX " " "70::有效网卡" "｜         ｜         ｜" "70.:全部网卡"
echo ￣￣￣￣￣          ｜          ￣￣￣￣￣
for /l %%i in (1,1,!n!) do Set /a n1=2*%%~i-1&Set /a n2=2*%%~i&(for %%j in ("!n1!") do Set dsk=!dsk%%~j!)&Call :EchoX "   " "9f::[!n1!]" "  " "xx::!dsk!:\Windows  ｜" "  " "9f::[!n2!]" "  " "xx.:!dsk!:\Windows"&echo                     ｜
echo ￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
Call :EchoX "e0:: 输入序号[" "e4::默认1" "e0::]：" " "&Set n=1&Set /p n=
Set Input=!dsk%n%!&if not defined Input Set Input=!n!
Set /a filter=!n!%%2&if !filter! == 1 (Set filter=有效网卡) else Set filter=全部网卡

:Start
Set Input=%Input:~0,1%
cd.>"%~dp0[%Input%盘]系统信息.txt"&&Set PCInfo="%~dp0[%Input%盘]系统信息.txt"||Set PCInfo="%TEMP%\[%Input%盘]系统信息.txt"
if /i "%Input%:" neq "%SystemDrive%" (
    Set OS=离线系统
    for %%a in (SOFTWARE SYSTEM) do if not exist "%Input%:\Windows\System32\Config\%%~a" Cls&Call :EchoX "cf.:找不到注册表文件！！"&echo "%Input%:\Windows\System32\Config\%%~a"&Call :Delay 5 +&Exit
    reg load HKLM\PC_SOF %Input%:\Windows\System32\Config\SOFTWARE 1>nul 2>nul
    reg load HKLM\PC_SYS %Input%:\Windows\System32\Config\SYSTEM 1>nul 2>nul
    Call :GetInfo PC_SOF PC_SYS
    reg unload HKLM\PC_SOF 1>nul 2>nul
    reg unload HKLM\PC_SYS 1>nul 2>nul
) else Set OS=在线系统&Call :GetInfo SOFTWARE SYSTEM
if exist %PCInfo% Cls&Call :EchoX "e0.: 获取完成，即将关闭！！！"&(msg_停用 1>nul 2>nul&&msg * /time 3600<%PCInfo%||@start "" %PCInfo%)
Call :Delay 2 +
Endlocal
Exit

:GetInfo
Title 获取%OS%信息&(if exist %WinDir%\System32\ureg.dll Mode 43,5 2>nul)&Color 2f&Cls&Call :EchoX "e0.: 正在获取，请稍等。。。"
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%~2\select" 2^>nul') do if /i "%%~a" == "Default" Set /a x=%%c
Set "-=------------------------------------------------------------"
Set "Cuv=Microsoft\Windows NT\CurrentVersion"
Set "Env=ControlSet00%x%\Control\Session Manager\Environment"
Set "Enum=ControlSet00%x%\Enum"
Set "Parameters=ControlSet00%x%\services\Tcpip\Parameters"
Set "LogonUI=Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
Set "Network=ControlSet00%x%\Control\Network"
Set "NetworkCards=Microsoft\Windows NT\CurrentVersion\NetworkCards"
Set "DeviceId=ControlSet00%x%\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
Set "NCKey=EnableDHCP NameServer IPAddress SubnetMask DefaultGateway DHCPNameServer DHCPIPAddress DHCPSubnetMask DHCPDefaultGateway"
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%~2\%Env%" 2^>nul') do if /i "%%~a" == "PROCESSOR_ARCHITECTURE" Set bit=%%c
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%~1\%Cuv%" 2^>nul') do (
    if /i "%%~a" == "SystemRoot" Set SR=%%c
    if /i "%%~a" == "ProductName" Set PN=%%c
    if /i "%%~a" == "DisplayVersion" Set DV=%%c 
    if /i "%%~a" == "CurrentVersion" Set CV=%%c
    if /i "%%~a" == "CurrentMajorVersionNumber" Set /a CN0+=%%c
    if /i "%%~a" == "CurrentMinorVersionNumber" Set /a CN1+=%%c&Set CN1=.!CN1!
    if /i "%%~a" == "CurrentBuildNumber" Set CBN=.%%c
    if /i "%%~a" == "UBR" Set /a UBR+=%%c&Set UBR=.!UBR!
    if /i "%%~a" == "InstallDate" Set /a ID+=%%c
)
if defined CN0 if defined CN1 Set CV=%CN0%%CN1%
if defined CBN if %CBN:~1% geq 22000 if defined PN Set PN=%PN: 10 = 11 %
Set yd=100365,110730,1211096,1301461,1401826,1502191,1612557,1702922,1803287,1903652,2014018,2104383,2204748,2305113,2415479,2505844,2606209,2706574,2816940,2907305,3007670,3108035,3218401,3308766,3409131,3509496,3619862,37010227
Set md=01031,02059,03090,040120,050151,060181,070212,080243,090273,100304,110334,120365
Set "OD=1262275200" :: 时间范围：2010年1月1日 - 2037年12月31日
Set /a d=(!ID!-!OD!)/(60*60*24)+1
Set /a h=(!ID!-!OD!)/(60*60)%%24
Set /a m=(!ID!-!OD!)/60%%60
Set /a s=(!ID!-!OD!)%%60
Set flag=&Set ly=&for %%i in (%yd%) do if not defined flag (
    Set ty=%%i
    if !d! leq !ty:~3! (Set flag=1) else Set ly=!ty!
)
Set yy=20!ty:~0,2!
if defined ly (Set /a dd=!d!-!ly:~3!) else Set dd=!d!
Set flag=&Set lm=&for %%i in (%md%) do if not defined flag (
    Set tm=%%i&if defined lm Set /a xm=!tm:~3!+!ty:~2,1!&Set tm=!tm:~0,3!!xm!
    if !dd! leq !tm:~3! (Set flag=1) else Set lm=!tm!
)
Set mm=!tm:~0,2!
if defined lm Set /a dd=!dd!-!lm:~3!
Set dd=0!dd!&Set h=0!h!&Set m=0!m!&Set s=0!s!
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%~2\%Parameters%" 2^>nul') do if /i "%%~a" == "Domain" (Set Domain=%%~c) else if /i "%%~a" == "HostName" Set HostName=%%c
Set LOUser=.\&(for /f "tokens=1,2*" %%a in ('reg query "HKLM\%~1\%LogonUI%" 2^>nul') do if /i "%%~a" == "LastLoggedOnUser" Set LOUser=%%c)&if "!LOUser:~0,2!" == ".\" Set LOUser=!LOUser:~2!
(echo 【%OS%】&echo.
 echo 计算机名：!HostName!
 echo 操作系统：[%SR%] %PN% 版本 %DV%^(%CV%%CBN%%UBR%^) x%bit:~-2%
 echo 安装时间：!yy!-!mm!-!dd:~-2! !h:~-2!:!m:~-2!:!s:~-2!
 echo 最后登录：!LOUser!
 echo 隶属于域：!Domain!) >%PCInfo%
Set n=&Set nc=1&for /f "delims=" %%a in ('reg query "HKLM\%~1\%NetworkCards%" 2^>nul') do (
    Set "v=%%~a"&if "!v:%NetworkCards%\=!" neq "!v!" (
        Set /a n+=1&for /f "tokens=1,2*" %%b in ('reg query "%%~a" 2^>nul') do if /i "%%~b" == "ServiceName" (Set "Guid!n!=%%~d") else if /i "%%~b" == "Description" (Set "NetCard!n!=%%~d"&if not defined "%%~d" (Set ""%%~d"=标识重复") else Set nc=0)
    )
)
for /l %%a in (1 1 !n!) do (
    Set flag=&for /f "delims=" %%b in ('reg query "HKLM\%~2\%Network%" /s /f "Name" /t REG_SZ 2^>nul') do if defined flag (
        for /f "tokens=1,2*" %%c in ("%%~b") do if /i "%%~c" == "Name" Set "Name%%~a=%%~e"& Set flag=
    ) else (
        Set "v=%%~b"&for %%c in ("\!Guid%%~a!") do if "!v:%%~c=!" neq "!v!" Set flag=1
    )
    Set flag=!nc!&for /f "tokens=1,2 delims=:" %%i in ('ipconfig /all 2^>nul') do (
        Set "key=%%~ix"&Set "value=%%~j"
        if "!flag!" == "0" for %%b in ("!Name%%~a!") do if "!key:%%~bx=!" neq "!key!" Set flag=1
        if "!flag!" == "1" if defined value for %%b in ("!NetCard%%~a!") do if "!value:%%~b=!" neq "!value!" Set flag=2
        if "!flag!" == "2" (
            if "!key:物理地址=!" neq "!key!" Set "Mac%%~a=!value:~1!"&Set flag=3
            if "!key:Physical Address=!" neq "!key!" Set "Mac%%~a=!value:~1!"&Set flag=3
        )
    )
    Set flag=&Set okey=&for /f "delims=" %%i in ('reg query "HKLM\%~2\%DeviceId%" /s /f "NetCfgInstanceId" /t REG_SZ 2^>nul') do (
        Set "value=%%~i"&if defined value for %%b in ("!Guid%%~a!") do if "!value:%%~b=!" neq "!value!" Set flag=1
        if not defined flag Set okey=!value!
    )
    for /f "tokens=1,2*" %%i in ('reg query "!okey!" /t REG_SZ 2^>nul') do (
        if /i "%%~i" == "DeviceInstanceID" Set "DeviceID%%~a=%%~k"&(reg query "HKLM\SYSTEM\%Enum%\%%~k\Control" 1>nul 2>nul&&Set NCE%%~a=1)
        if /i "%%~i" == "NetworkAddress" Set "MAC=%%~k"&if defined MAC Set "_MAC%%~a=!MAC:~0,2!-!MAC:~2,2!-!MAC:~4,2!-!MAC:~6,2!-!MAC:~8,2!-!MAC:~10,2! [修改值]"&if defined MAC%%a if "!MAC%%~a!" neq "!_MAC%%~a:~0,17!" (Set "MAC%%~a=!MAC%%~a! [真实值]  ") else Set "MAC%%~a=!MAC%%~a! [修改值]"
    )
)
(if defined n echo.&echo %-%&echo 【!filter!】) >>%PCInfo%
for %%a in (%NCKey%) do Set "_%%~a=1"
for /l %%a in (1 1 !n!) do if "!filter!" == "有效网卡" if not defined MAC%%~a if not defined NCE%%~a Set "MAC%%~a=无效网卡"
(for /l %%a in (1 1 !n!) do if "!MAC%%~a!" neq "无效网卡" (
    echo.&echo 网卡描述：!NetCard%%~a!
    echo 连接名称：!Name%%~a!
    if /i "%Input%:" neq "%SystemDrive%" (echo 物理地址：!MAC%%~a!!_MAC%%~a!) else echo 物理地址：!MAC%%~a!
    for /f "tokens=1,2,3 delims=\" %%b in ("!DeviceID%%~a!") do echo 硬件ＩＤ：%%~b\%%~c
    for %%b in (%NCKey%) do Set "%%~b="
    for /f "tokens=1,2*" %%b in ('reg query "HKLM\%~2\%Parameters%\Interfaces\!Guid%%~a!" 2^>nul') do if defined _%%b if "%%~d" neq "" Set "v=%%~d"&Set "%%~b=!v:\0=	!"
    if defined IPAddress (echo ＩＰ地址：!IPAddress!) else if defined DHCPIPAddress (Set DHCPIPAddress=!DHCPIPAddress!               &echo ＩＰ地址：!DHCPIPAddress:~0,15! [自动获取]) else echo ＩＰ地址：
    if defined SubnetMask (echo 子网掩码：!SubnetMask!) else echo 子网掩码：!DHCPSubnetMask!
    if defined DefaultGateway (echo 默认网关：!DefaultGateway!) else echo 默认网关：!DHCPDefaultGateway!
    Set /p="DNS 地址："<nul&if defined NameServer (Set DNS=!NameServer: =,!&Set dhcp=) else if defined DHCPNameServer (Set DNS=!DHCPNameServer: =,!&Set dhcp= [自动获取]) else Set DNS=&Set dhcp=&echo.
    Set b=&for %%b in (!DNS!) do if not defined "n%%~a_%%~b" Set ""n%%~a_%%~b"=%%~b               "&(if defined dhcp (echo !"n%%~a_%%~b":~0,15!!dhcp!&Set dhcp=) else echo !b!%%~b)&Set b=　　　　　
)) >>%PCInfo%
Set vb=0&for /f "tokens=2 delims=[]" %%a in ('ver') do for /f "tokens=2-4 delims=. " %%b in ("%%~a") do Set "vb=%%~d"
if /i "%Input%:" == "%SystemDrive%" (
    echo.&echo %-%&echo 【登录过的 WiFi 名称和密码】
    if %vb% geq 26100 chcp 65001 1>nul 2>nul
    for /l %%a in (1 1 !n!) do (
        Set flag=&for /f "skip=8 tokens=2 delims=:" %%i in ('netsh wlan show profiles interface^="!Name%%~a!" 2^>nul') do (
            if not defined flag echo.&echo  [!Name%%~a! 无线网卡]↓&Set flag=x
            Set "WiFi=%%~i"&Set "WiFi=!WiFi:~1!"
            for /f "skip=12 tokens=1,2 delims=:" %%j in ('netsh wlan show profile name^="!WiFi!" key^=clear 2^>nul') do (
                Set "Key=%%~j"&Set "Key=!Key: =!"&Set Pass=
                if "!Key!" == "关键内容" Set "Pass=x%%~k"
                if /i "!Key!" == "KeyContent" Set "Pass=x%%~k"
                if defined Pass echo.&echo 　　　WiFi 名称  ..... : !WiFi!&echo 　　　　　 密码  ..... : !Pass:~2!
            )
        )
    )
    if %vb% geq 26100 chcp 936 1>nul 2>nul
) >>%PCInfo%
Goto :eof

:Delay :: 延迟操作 <%1=Sec|延迟秒数> [%2=+|显示倒计时]。
if "%~2" == "+" (Set #=2) else Set #=1
if exist %WinDir%\System32\timeout.exe (timeout /t %~1 %#%>nul) else if exist %WinDir%\System32\choice.exe (choice /t %~1 /d y /n >nul) else ping 127.1 -n %~1 >nul
Goto :eof

:EchoX :: 显示彩色文字 (不支持半角字符 \ / : * ? " < >|. % ! ~)。
Setlocal EnableDelayedExpansion
Set echox=EchoX.exe&&!echox! 1>nul 2>nul||(Set echox=&mkdir "%TEMP%\EchoX" 2>nul&&attrib +s +h "%TEMP%\EchoX" 2>nul)
for %%a in (%*) do (
    Set "param=%%~a"&Set "color=!param:~0,2!"&(if not exist %WinDir%\System32\findstr.exe if not defined echox Set "color=xx")
    Set n=0&(if "!param:~2,2!" == "::" Set n=1)&(if "!param:~2,2!" == ".:" Set n=2)
    if !n! gtr 0 (
        if /i "!color!" == "xx" (Set /p="_!param:~4!"<nul) else (Set param=%%~nxa&if defined echox (!echox! -c !color! -n "!param:~4!") else (Pushd "%TEMP%\EchoX" 2>nul&>"!param:~4!",Set /p= <nul&findstr /a:!color! .* "!param:~4!*"&del "!param:~4!"&Popd))
        if !n! == 2 echo.
    ) else if defined param Set /p="_!param!"<nul
)
Endlocal&Goto :eof