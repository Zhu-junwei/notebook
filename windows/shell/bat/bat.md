[TOC]

# @

> 关闭当前命令行回显
>
> 放在命令前，它的作用是让执行窗口中，无论echo是否为打开状态， 都不显示它后面这一行的命令本身。

# echo

> 回显命令

**语法：**

```
C:\Users\jw>echo /?
显示消息，或者启用或关闭命令回显。

  ECHO [ON | OFF]
  ECHO [message]

若要显示当前回显设置，请键入不带参数的 ECHO。
```

**参数说明：**

```
echo on 
```

> 打开回显

一般系统默认都是`echo on`，所以这个代码不常用，除了执行过`echo  off` 后，想再次回显才会用到`echo on`。

```
echo off 
```

> 关闭回显

执行`echo off` 可以关闭掉后面所有批处理命令的回显，只显示执行后 的结果，除非再次执行`echo on`命令。但`echo off`无法关掉`echo off`这个命令本身。我们可在其前面添加`@`，就可以达到所有命令都不显示的目的，直到执行`echo on`为止。所以，我们一般都用`@echo off` 作为批处理的行首，取消所有的批处理命令回显，可以说，`@echo off` 放在程序首行，已经成为批处理程序的标志。有的人习惯不以`@echo  off`作为行首，而改为在每行命令前加`“@”`，这个太繁琐，应该用 `@echo off` 简洁。

```
echo+空格 
```

> 查询当前计算机的回显状态，也就是看看当前回显是打开的还是关闭 的。

```
echo+信息
```

> 显示信息  

注意，echo后必须紧跟一个空格或特殊字符，以区分echo命令和信息，该空格或特殊字符不会作为信息被显示出来。  

例如：  

`echo Hello World!  `

`echo.Hello World! ` 

`echo/Hello World!  `

三个都是等效的。

```
echo. 
```

> 显示一个空行，相当于一个回车。

注意：`“echo”`与`“.”`之间不能有空格，否则`“.”`将被当做提示信息输出到屏幕。另外`“.”`可以用 `,` ` : ` ` ;`  `/`  `[`  `\`  `]`  `+`  `(` ` =` 等任意 一个符号替代，不过几乎所有人都只用`“echo.”`这一种形式。

```
echo 文件内容>文件名
```

> 将文件内容输出到指定文件中。如果指定的文件中原有别的信息，原先的信息将被清空。

```
echo 文件内容>>文件名
```

> 将文件内容追加到指定文件中。如果指定的文件中原有别的信息，原先的信息不会被清空。

# rem

```
C:\Users\jw>rem /?
在批处理文件或 CONFIG.SYS 里加上注解或说明。

REM [comment]
```

**和`::`的不同之处：**

- 当打开回显时，`rem`后的内容会显示出来，然而`::`后的内容仍然不会显示。 

# pause

```
C:\Users\jw>pause /?
暂停批处理程序，并显示以下消息:
    请按任意键继续. . .
```

```
pause>nul
```

> 不显示""请按任意键继续. . ."回显

```
echo 按N键退出当前程序 & pause>nul 
```

> 达到替换提示词的效果

# title

```
C:\Users\jw>title /?
设置命令提示窗口的窗口标题。

TITLE [string]

  string       指定命令提示窗口的标题。
```

示例：

```
title 批处理教程
```

# color

```
C:\Users\jw>color /?
设置默认的控制台前景和背景颜色。

COLOR [attr]

  attr        指定控制台输出的颜色属性。

颜色属性由两个十六进制数字指定 -- 第一个
对应于背景，第二个对应于前景。每个数字
可以为以下任何值:

    0 = 黑色       8 = 灰色
    1 = 蓝色       9 = 淡蓝色
    2 = 绿色       A = 淡绿色
    3 = 浅绿色     B = 淡浅绿色
    4 = 红色       C = 淡红色
    5 = 紫色       D = 淡紫色
    6 = 黄色       E = 淡黄色
    7 = 白色       F = 亮白色

如果没有给定任何参数，此命令会将颜色还原到 CMD.EXE 启动时
的颜色。这个值来自当前控制台
窗口、/T 命令行开关或 DefaultColor 注册表
值。

如果尝试使用相同的
前景和背景颜色来执行
 COLOR 命令，COLOR 命令会将 ERRORLEVEL 设置为 1。
```

示例：

```
color 12
```

# mode

```
C:\Users\jw>mode /?
配置系统设备。

串行端口:          MODE COMm[:] [BAUD=b] [PARITY=p] [DATA=d] [STOP=s]
                                [to=on|off] [xon=on|off] [odsr=on|off]
                                [octs=on|off] [dtr=on|off|hs]
                                [rts=on|off|hs|tg] [idsr=on|off]

设备状态:          MODE [device] [/STATUS]

打印重定向:        MODE LPTn[:]=COMm[:]

选择代码页:        MODE CON[:] CP SELECT=yyy

代码页状态:        MODE CON[:] CP [/STATUS]

显示模式:          MODE CON[:] [COLS=c] [LINES=n]

击键率:            MODE CON[:] [RATE=r DELAY=d]
```

示例：

> 设置窗口大小

```
mode con cols=130 lines=20
```

在**Windows Terminal**中失效。

# goto

```
C:\Users\jw>goto /?
将 cmd.exe 定向到批处理程序中带标签的行。

GOTO label

  label   指定批处理程序中用作标签的文字字符串。

标签必须单独一行，并且以冒号打头。

如果启用了命令扩展，则 GOTO 将按如下所示更改:

GOTO 命令现在接受目标标签 :EOF，用于传输控件
到当前批处理脚本文件的末尾。这是一种简单的方法
退出批处理脚本文件而不定义标签。键入 CALL /? 用于
创建此功能的 CALL 命令的扩展说明
有用。

执行 GOTO: 在具有目标标签的 CALL 将返回控件
CALL 后紧接的语句。
```



# start

```
C:\Users\jw>start /?
启动一个单独的窗口以运行指定的程序或命令。

START ["title"] [/D path] [/I] [/MIN] [/MAX] [/SEPARATE | /SHARED]
      [/LOW | /NORMAL | /HIGH | /REALTIME | /ABOVENORMAL | /BELOWNORMAL]
      [/NODE <NUMA node>] [/AFFINITY <hex affinity mask>] [/WAIT] [/B]
      [/MACHINE <x86|amd64|arm|arm64>][command/program] [parameters]

    "title"     在窗口标题栏中显示的标题。
    path        启动目录。
    B           启动应用程序，但不创建新窗口。
                应用程序已忽略 ^C 处理。除非应用程序
                启用 ^C 处理，否则 ^Break 是唯一可以中断
                该应用程序的方式。
    I           新的环境将是传递
                给 cmd.exe 的原始环境，而不是当前环境。
    MIN         以最小化方式启动窗口。
    MAX         以最大化方式启动窗口。
    SEPARATE    在单独的内存空间中启动 16 位 Windows 程序。
    SHARED      在共享内存空间中启动 16 位 Windows 程序。
    LOW         在 IDLE 优先级类中启动应用程序。
    NORMAL      在 NORMAL 优先级类中启动应用程序。
    HIGH        在 HIGH 优先级类中启动应用程序。
    REALTIME    在 REALTIME 优先级类中启动应用程序。
    ABOVENORMAL 在 ABOVENORMAL 优先级类中启动应用程序。
    BELOWNORMAL 在 BELOWNORMAL 优先级类中启动应用程序。
    NODE        将首选非一致性内存结构(NUMA)
                节点指定为十进制整数。
    AFFINITY    将处理器关联掩码指定为十六进制数字。

                将 /AFFINITY 和
                 /NODE 结合使用时，会对关联掩码进行不同的解释。指定关联掩码，就将 NUMA
                节点的处理器掩码向右移位以从零位开始一样。
                进程被限制在指定关联掩码和 NUMA 节点之间的
                那些通用处理器上运行。
                如果没有通用处理器，则进程被限制在
                指定的 NUMA 节点上运行。
    WAIT        启动应用程序并等待它终止。
    MACHINE     指定应用程序进程的系统架构。

    command/program
                如果它是内部 cmd 命令或批文件，则
                该命令处理器是使用 cmd.exe 的 /K 开关运行的。
                这表示运行命令
                之后，该窗口将仍然存在。

                如果它不是内部 cmd 命令或批处理文件，则
                它就是一个程序，并将作为一个窗口化应用程序或
                控制台应用程序运行。

    parameters  这些是传递给 command/program 的参数。

注意: 在 64 位平台上不支持 SEPARATE 和 SHARED 选项。

通过指定 /NODE，可按照利用 NUMA 系统中的内存
区域的方式创建进程。例如，可以创建两个完全通过共享内存互相
通信的进程以共享相同的
首选 NUMA 节点，从而最大限度地减少内存延迟。只要有可能，它们就会分配
来自相同 NUMA 节点的内存，并且会在指定节点之外的
处理器上自由运行。

    start /NODE 1 application1.exe
    start /NODE 1 application2.exe

这两个进程可被进一步限制
在相同 NUMA 节点内的指定处理器上运行。在以下示例中，application1 在节点的两个
低位处理器上运行，而 application2在该节点的其后两个
处理器上运行。该示例假定指定节点至少具有
四个逻辑处理器。请注意，节点号可更改为该计算机的任何有效
节点号，而无需更改关联掩码。

    start /NODE 1 /AFFINITY 0x3 application1.exe
    start /NODE 1 /AFFINITY 0xc application2.exe

如果命令扩展被启用，通过命令行或 START 命令的外部命令
调用会如下改变:

将文件名作为命令键入，非可执行文件可以通过文件关联调用。
    (例如，WORD.DOC 会调用跟 .DOC 文件扩展名关联的应用程序)。
    关于如何从命令脚本内部创建这些关联，请参阅 ASSOC 和
     FTYPE 命令。

执行的应用程序是 32 位 GUI 应用程序时，CMD.EXE 不等应用
    程序终止就返回命令提示符。如果在命令脚本内执行，该新行为
    则不会发生。

如果执行的命令行的第一个符号是不带扩展名或路径修饰符的
    字符串 "CMD"，"CMD" 会被 COMSPEC 变量的数值所替换。这
    防止从当前目录提取 CMD.EXE。

如果执行的命令行的第一个符号没有扩展名，CMD.EXE 会使用
    PATHEXT 环境变量的数值来决定要以什么顺序寻找哪些扩展
    名。PATHEXT 变量的默认值是:

        .COM;.EXE;.BAT;.CMD

    请注意，该语法跟 PATH 变量的一样，分号隔开不同的元素。

查找可执行文件时，如果没有相配的扩展名，看一看该名称是否
与目录名相配。如果确实如此，START 会在那个路径上调用
Explorer。如果从命令行执行，则等同于对那个路径作 CD /D。
```



# shift

```
C:\Users\jw>shift /?
更改批处理文件中可替换参数的位置。

SHIFT [/n]

如果命令扩展被启用，SHIFT 命令支持/n 命令行开关；该命令行开关告诉
命令从第 n 个参数开始移位；n 介于零和八之间。例如:

    SHIFT /2

会将 %3 移位到 %2，将 %4 移位到 %3，等等；并且不影响 %0 和 %1。
```

# set

```
C:\Users\jw>set /?
显示、设置或删除 cmd.exe 环境变量。

SET [variable=[string]]

  variable  指定环境变量名。
  string    指定要指派给变量的一系列字符串。

要显示当前环境变量，键入不带参数的 SET。

如果命令扩展被启用，SET 会如下改变:

可仅用一个变量激活 SET 命令，等号或值不显示所有前缀匹配
SET 命令已使用的名称的所有变量的值。例如:

    SET P

会显示所有以字母 P 打头的变量

如果在当前环境中找不到该变量名称，SET 命令将把 ERRORLEVEL
设置成 1。

SET 命令不允许变量名含有等号。

在 SET 命令中添加了两个新命令行开关:

    SET /A expression
    SET /P variable=[promptString]

/A 命令行开关指定等号右边的字符串为被评估的数字表达式。该表达式
评估器很简单并以递减的优先权顺序支持下列操作:

    ()                  - 分组
    ! ~ -               - 一元运算符
    * / %               - 算数运算符
    + -                 - 算数运算符
    << >>               - 逻辑移位
    &                   - 按位“与”
    ^                   - 按位“异”
    |                   - 按位“或”
    = *= /= %= += -=    - 赋值
      &= ^= |= <<= >>=
    ,                   - 表达式分隔符
    
如果你使用任何逻辑或取余操作符， 你需要将表达式字符串用
引号扩起来。在表达式中的任何非数字字符串键作为环境变量
名称，这些环境变量名称的值已在使用前转换成数字。如果指定
了一个环境变量名称，但未在当前环境中定义，那么值将被定为
零。这使你可以使用环境变量值做计算而不用键入那些 % 符号
来得到它们的值。如果 SET /A 在命令脚本外的命令行执行的，
那么它显示该表达式的最后值。该分配的操作符在分配的操作符
左边需要一个环境变量名称。除十六进制有 0x 前缀，八进制
有 0 前缀的，数字值为十进位数字。因此，0x12 与 18 和 022
相同。请注意八进制公式可能很容易搞混: 08 和 09 是无效的数字，
因为 8 和 9 不是有效的八进制位数。(& )

/P 命令行开关允许将变量数值设成用户输入的一行输入。读取输入
行之前，显示指定的 promptString。promptString 可以是空的。

环境变量替换已如下增强:

    %PATH:str1=str2%

会扩展 PATH 环境变量，用 "str2" 代替扩展结果中的每个 "str1"。
要有效地从扩展结果中删除所有的 "str1"，"str2" 可以是空的。
"str1" 可以以星号打头；在这种情况下，"str1" 会从扩展结果的
开始到 str1 剩余部分第一次出现的地方，都一直保持相配。

也可以为扩展名指定子字符串。

    %PATH:~10,5%

会扩展 PATH 环境变量，然后只使用在扩展结果中从第 11 个(偏
移量 10)字符开始的五个字符。如果没有指定长度，则采用默认
值，即变量数值的余数。如果两个数字(偏移量和长度)都是负数，
使用的数字则是环境变量数值长度加上指定的偏移量或长度。

    %PATH:~-10%

会提取 PATH 变量的最后十个字符。

    %PATH:~0,-2%

会提取 PATH 变量的所有字符，除了最后两个。
终于添加了延迟环境变量扩充的支持。该支持总是按默认值被
停用，但也可以通过 CMD.EXE 的 /V 命令行开关而被启用/停用。
请参阅 CMD /?

考虑到读取一行文本时所遇到的目前扩充的限制时，延迟环境
变量扩充是很有用的，而不是执行的时候。以下例子说明直接
变量扩充的问题:

    set VAR=before
    if "%VAR%" == "before" (
        set VAR=after
        if "%VAR%" == "after" @echo If you see this, it worked
    )

不会显示消息，因为在读到第一个 IF 语句时，BOTH IF 语句中
的 %VAR% 会被代替；原因是: 它包含 IF 的文体，IF 是一个
复合语句。所以，复合语句中的 IF 实际上是在比较 "before" 和
"after"，这两者永远不会相等。同样，以下这个例子也不会达到
预期效果:

    set LIST=
    for %i in (*) do set LIST=%LIST% %i
    echo %LIST%

原因是，它不会在目前的目录中建立一个文件列表，而只是将
LIST 变量设成找到的最后一个文件。这也是因为 %LIST% 在
FOR 语句被读取时，只被扩充了一次；而且，那时的 LIST 变量
是空的。因此，我们真正执行的 FOR 循环是:

    for %i in (*) do set LIST= %i

这个循环继续将 LIST 设成找到的最后一个文件。

延迟环境变量扩充允许你使用一个不同的字符(惊叹号)在执行
时间扩充环境变量。如果延迟的变量扩充被启用，可以将上面
例子写成以下所示，以达到预期效果:

    set VAR=before
    if "%VAR%" == "before" (
        set VAR=after
        if "!VAR!" == "after" @echo If you see this, it worked
    )

    set LIST=
    for %i in (*) do set LIST=!LIST! %i
    echo %LIST%

如果命令扩展被启用，有几个动态环境变量可以被扩展，但不会出现在 SET 显示的变
量列表中。每次变量数值被扩展时，这些变量数值都会被动态计算。如果用户用这些
名称中任何一个明确定义变量，那个定义会替代下面描述的动态定义:

%CD% - 扩展到当前目录字符串。

%DATE% - 用跟 DATE 命令同样的格式扩展到当前日期。

%TIME% - 用跟 TIME 命令同样的格式扩展到当前时间。

%RANDOM% - 扩展到 0 和 32767 之间的任意十进制数字。

%ERRORLEVEL% - 扩展到当前 ERRORLEVEL 数值。

%CMDEXTVERSION% - 扩展到当前命令处理器扩展版本号。

%CMDCMDLINE% - 扩展到调用命令处理器的原始命令行。

%HIGHESTNUMANODENUMBER% - 扩展到此计算机上的最高 NUMA 节点号。

```





# SC

```
描述:
        SC 是用来与服务控制管理器和服务进行通信
        的命令行程序。
用法:
        sc <server> [command] [service name] <option1> <option2>...


        <server> 选项的格式为 "\\ServerName"
        可通过键入以下命令获取有关命令的更多帮助: "sc [command]"
        命令:
          query-----------查询服务的状态，
                          或枚举服务类型的状态。
          queryex---------查询服务的扩展状态，
                          或枚举服务类型的状态。
          start-----------启动服务。
          pause-----------向服务发送 PAUSE 控制请求。
          interrogate-----向服务发送 INTERROGATE 控制请求。
          continue--------向服务发送 CONTINUE 控制请求。
          stop------------向服务发送 STOP 请求。
          config----------更改服务的配置(永久)。
          description-----更改服务的描述。
          failure---------更改失败时服务执行的操作。
          failureflag-----更改服务的失败操作标志。
          sidtype---------更改服务的服务 SID 类型。
          privs-----------更改服务的所需特权。
          managedaccount--更改服务以将服务帐户密码
                          标记为由 LSA 管理。
          qc--------------查询服务的配置信息。
          qdescription----查询服务的描述。
          qfailure--------查询失败时服务执行的操作。
          qfailureflag----查询服务的失败操作标志。
          qsidtype--------查询服务的服务 SID 类型。
          qprivs----------查询服务的所需特权。
          qtriggerinfo----查询服务的触发器参数。
          qpreferrednode--查询服务的首选 NUMA 节点。
          qmanagedaccount-查询服务是否将帐户
                          与 LSA 管理的密码结合使用。
          qprotection-----查询服务的进程保护级别。
          quserservice----查询用户服务模板的本地实例。
          delete ----------(从注册表中)删除服务。
          create----------创建服务(并将其添加到注册表中)。
          control---------向服务发送控制。
          sdshow----------显示服务的安全描述符。
          sdset-----------设置服务的安全描述符。
          showsid---------显示与任意名称对应的服务 SID 字符串。
          triggerinfo-----配置服务的触发器参数。
          preferrednode---设置服务的首选 NUMA 节点。
          GetDisplayName--获取服务的 DisplayName。
          GetKeyName------获取服务的 ServiceKeyName。
          EnumDepend------枚举服务依赖关系。
        
        以下命令不需要服务名称:
        sc <server> <command> <option>
          boot------------(ok | bad)指示是否应将上一次启动另存为
                          最近一次已知的正确启动配置
          Lock------------锁定服务数据库
          QueryLock-------查询 SCManager 数据库的 LockStatus
示例:
        sc start MyService


QUERY 和 QUERYEX 选项:
        如果查询命令带服务名称，将返回
        该服务的状态。其他选项不适合这种
        情况。如果查询命令不带参数或
        带下列选项之一，将枚举此服务。
    type=    要枚举的服务的类型(driver, service, userservice, all)
             (默认 = service)
    state=   要枚举的服务的状态 (inactive, all)
             (默认 = active)
    bufsize= 枚举缓冲区的大小(以字节计)
             (默认 = 4096)
    ri=      开始枚举的恢复索引号
             (默认 = 0)
    group=   要枚举的服务组
             (默认 = all groups)

语法示例
sc query                - 枚举活动服务和驱动程序的状态
sc query eventlog       - 显示 eventlog 服务的状态
sc queryex eventlog     - 显示 eventlog 服务的扩展状态
sc query type= driver   - 仅枚举活动驱动程序
sc query type= service  - 仅枚举 Win32 服务
sc query state= all     - 枚举所有服务和驱动程序
sc query bufsize= 50    - 枚举缓冲区为 50 字节
sc query ri= 14         - 枚举时恢复索引 = 14
sc queryex group= ""    - 枚举不在组内的活动服务
sc query type= interact - 枚举所有不活动服务
sc query type= driver group= NDIS     - 枚举所有 NDIS 驱动程序
```

## 启动服务

```shell
//启动mysql服务
sc start mysql
//启动clouddriveservice
sc start clouddriveservice
```

## 停止服务

```powershell
//停止mysql服务
sc stop mysql
//停止clouddriveservice
sc stop clouddriveservice
```

## 设置服务启动类型

> sc <server> config [服务名称] <option1> <option2>...

```powershell
//设置为手动启动
sc config mysql start=demand
//设置为禁用
sc config mysql start=disabled
//设置为自动
sc config mysql start=auto
//设置为自动（延迟启动）
sc config mysql start=delayed-auto
```

## 创建服务

> sc create
>
> 描述:
> 在注册表和服务数据库中创建服务项。
> 用法:
> sc <server> create [service name] [binPath= ] <option1> <option2>...


```powershell
sc create clouddrive binPath=D:\CloudDrive\CloudDriveService.exe start=auto
```

## 设置服务的描述

> sc description
> 描述:
> 设置服务的描述字符串。
> 用法:
> sc <server> description [service name] [description]


```powershell
sc description clouddrive "这是我创建的第一个服务"
```

## 卸载服务

> sc delete
> 描述:
> 从注册表删除服务项。
> 如果服务正在运行，或另一进程已经打开
> 到此服务的句柄，服务将简单地标记为
> 删除。
> 用法:
> sc <server> delete [service name]


```powershell
sc delete clouddrive
```

## 参考资料

[SC命令详解 - 森大科技 - 博客园](https://www.cnblogs.com/cnsend/p/12907229.html)


# 查看端口占用

```bash
netstat -ano | findstr <端口号>
```

# 杀死进程

```bash
# 使用 taskkill 命令加上进程ID来终止进程。
taskkill /PID <进程ID>
# 如果需要强制终止进程，可以添加 /F 参数
taskkill /F /PID <进程ID>
```
