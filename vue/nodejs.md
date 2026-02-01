# npm

> npm: Node Package Manager, 是Node.js的包管理工具

## 查看npm配置

```
npm config list
```

## 配置npm的全局模块的安装路径

使用管理员身份运行命令行，在命令行中，执行如下指令：

```
npm config set prefix "E:\nodejs"
```

## 设置安装包的源

查看默认的源：

```
npm config get registry
```

淘宝源：

```
npm config set registry https://registry.npmmirror.com
```

官方源：

```
npm config set registry https://registry.npmjs.org
```

## 缓存设置

查看缓存路径：

```
npm config get cache
```

清空缓存：

```
npm cache clean
```

## 查看依赖

查看所有已安装的模块：

```
npm list
```

查看全局已安装的模块：

```
npm list -g --depth=0
```

查看某个模块的详细信息：

```
npm list <package-name>
```

## 卸载依赖

卸载某个模块：

```
npm uninstall <package-name>
````

卸载并删除模块的依赖项：

```
npm uninstall <package-name> --save
```

卸载全局模块：

```
npm uninstall -g <package-name>
```

## 更新依赖

更新项目中的所有依赖：

```
npm update
```

更新某个特定的模块：

```
npm update <package-name>
```

# pnpm

> pnpm 是一个高效的包管理工具，与 npm 类似，但它在包的管理方式上更加节省磁盘空间，并提高安装速度。

## 安装 pnpm

如果你还没有安装 pnpm，可以用以下命令通过 npm 来安装：

```bash
npm install -g pnpm
```

固定 pnpm store 位置

```
pnpm config set store-dir E:\SDK\pnpm-store
```

验证：

```
pnpm store path
```

## 更新包

```
pnpm update -g <package>
```

