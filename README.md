# EXE-Revision

使用 [SubWCRev][s] 或 [GitWCRev][g] 将源代码的版本号（数值或 sha），

通过 Visual Studio 的 `version.rc` 资源文件，

给生成的可执行文件（exe/dll）增加文件版本+产品版本，

以便从用户或客户等终端追溯源代码版本。

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

[s]:https://tortoisesvn.net/docs/release/TortoiseSVN_zh_CN/tsvn-subwcrev.html
[g]:https://tortoisegit.org/docs/tortoisegit/tgit-gitwcrev.html