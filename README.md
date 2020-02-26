# EXE-Revision

使用 [SubWCRev][s] 或 [GitWCRev][g] 将源代码的版本号（数值或 sha），

通过 Visual Studio 的 `version.rc` 资源文件，

给生成的可执行文件（exe/dll）增加文件版本+产品版本，

以便从用户或客户等终端追溯源代码版本。

使用 git 时，请将 `pre-push` 拷贝到 `.git/hooks/` 目录中，约束推送行为。

## SubWCRev 程序

> 你可以只对工作副本使用 SubWCRev，而不是直接对版本库。摘自 [SubWCRev 程序][s]

使用 SubWCRev.exe 时需要指定工作目录，如果指定的工作目录不合理就会：

- 执行失败。比如指定的目录并非 Subversion 的有效工作副本
- 造成 exe/dll 中打的 revision 没有意义。比如 `SubWCRev ./ src.tmpl version.rc`，但在 `./` 之外的源码也在项目中使用，并做了更改。

    如果 `./` 中也做了修改：那么确保 `./` 之外的修改优先提交，最后提交 `./` 中的修改；如果 `./` 未作修改，那就无能为力了。

所以，应该确保 WorkingCopyPath 已经**完整地**包含了项目中需要的所有内容，无 WorkingCopyPath 之外的依赖。

把执行命令/脚本 `SubWCRev ./ src.tmpl version.rc` 作为生成事件使用时，注意项目“生成”和“重新生成”的区别：前者可能并不触发生成事件。需要检验生成目标的版本信息。

当工作副本中存在未提交内容/未做版本控制的内容时，是否中断生成？

`SubWCRev ./ src.tmpl version.rc -nNm`

## GitWCRev 程序

在开发过程中，出现了以下现象：

GitWCRev 总是报错（或警告）“uncommitted modifications”，但是使用 `git status` 却提示工作区是干净的。

怎么排查也没找到问题的原因。最终通过 ~~删除整个工作区（保留 `.git` 目录）重新检出内容，不再报错~~。问题再次复现后，只删除 visual studio 的 `.sln` 和 `.vcxproj*` 等文件重新检出，就能修复。似乎和通过 git 编辑这些文件有关。

## Powershell

在 Visual Studio 2015 生成事件中，使用 powershell 报错 “执行 Microsoft.PowerShell_profile.ps1 无权限”，可是通过开始菜单或 shift+右击，运行 powershell 正常。

查找原因如下：

1. Powershell 启动时会首先执行 Microsoft.PowerShell_profile.ps1
2. 系统自带 [两套 powershell][5]，两套 cmd，区分 win32 和 x64

    > there is an x64 and x86 version of PowerShell both of which have to have their execution policies set. 

3. 操作顺利的 powershell 位于 System32 中，Visual Studio 2015 使用的 powershell 位于 SysWOW64 中。前者调整了脚本执行策略，而后者没有。
4. 此时通过后者的 cmd 以管理员权限执行 `powershell Set-ExecutionPolicy RemoteSigned` 也报错无法生效
5. 因为 powershell 启动就会预先执行 Microsoft.PowerShell_profile.ps1，需要解除这个循环套。把脚本重命名，重复步骤 4 即可（记得恢复脚本名称）

为什么 vs2015 会用 SysWOW64 中的 powershell，暂时没有找到依据。

## 资源文件

使用脚本提高自动化的程度。

### 支持 UTF8NoBOM

Visual Stdio 2015 对于 .rc 文件的编码敏感，如果使用 UTF-8 编码（默认是 UTF-16LE BOM），需要在 .rc 文件中 [增加编译选项][2]
```cpp
 #pragma code_page(65001)
```

- 暂时 [没有找到方法][1] 支持 UTF-8-BOM 编码
- 资源文件的编译，和 c/cpp 源文件的编译不相关。针对 c/c++ 编译的 `/utf-8` 操作对资源文件无效。

    > RC does not support the pragma directives supported by the C/C++ compiler. 

### 内容替换

Windows Powershell（[不同于 Powershell Core][3]）版本最高到 5.1，其 `Out-File -Encoding` 不支持 `UTF8NoBOM`，而 `UTF8` 选项又模棱两可，实际测试输出文件编码为 UTF-8-BOM。

而 Powershell Core 在这方面就友好很多，默认编码就是 `UTF8NoBOM`，而非 Powershell 5.1 的 `Unicode`(UTF-16LE BOM)，但 Powershell Core 需要单独安装，系统自带的是 Windows Powershell。

> 如果你对 PowerShell 6 及更高版本感兴趣，则需要安装 PowerShell Core 而不是 Windows PowerShell。

如果需要对资源文件模板做自定义的内容替换（非 xxWCRev.exe 工具），应该如何做呢？

- 比如以项目的实际输出文件名，更新资源文件中的 `InternalName` 和 `OriginalFilename` 原始文件名称
- 比如要根据仓库类型 git/svn，调整 `$WCREV=7$` 和 `$WCREV$`。svn 不支持前者，git 使用后者又太长。

只需要正确的读出文件内容，就能够达到我们的目的了。

[`Get-Content -Encoding`][4] 默认编码是 `Default`，在中文环境中大概率会出错：

> `Default` Uses the encoding that corresponds to the system's active code page (usually ANSI).

[s]:https://tortoisesvn.net/docs/release/TortoiseSVN_zh_CN/tsvn-subwcrev.html
[g]:https://tortoisegit.org/docs/tortoisegit/tgit-gitwcrev.html
[1]:https://developercommunity.visualstudio.com/content/problem/384705/visualstudio-v1590-resource-editor-using-utf-8-bom.html
[2]:https://docs.microsoft.com/en-us/windows/win32/menurc/pragma-directives
[3]:https://docs.microsoft.com/zh-cn/powershell/scripting/install/installing-windows-powershell?view=powershell-7
[4]:https://docs.microsoft.com/zh-cn/powershell/module/Microsoft.PowerShell.Management/Get-Content?view=powershell-5.1
[5]:https://stackoverflow.com/a/18533754/6728820