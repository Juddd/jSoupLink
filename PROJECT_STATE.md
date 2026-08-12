# PROJECT_STATE

## Goal / 目标

在上游 `feature/rel1.1` 基础上完成并发布可在 Wolfram 15.0/Linux 正常安装使用的 `jsoupLink` 1.1.0，不新增既定范围外的功能。

## Progress / 当前进度

- 基线：`d5a3456`（上游 `feature/rel1.1`）。
- 当前分支：`maint/1.1.0`。
- 已 cherry-pick Felix Kasza 的 PR #8 构建提交并保留作者信息；入口已落在 `jsoupLink/Kernel/jsoupLink.wl`。
- 已完成 #4 的入口/元数据修复、锁定 #5、更新 jsoup、补全文档/许可证/测试和唯一构建入口。
- 已提交并发布到 `Juddd/jSoupLink`；1.1.0 tag 与 Release 均指向已验证的维护提交。

## Decisions / 关键决定

- 保留旧属性式 API 和 `Global`HTMLElement`。
- 保留作者新增的 8 个辅助函数；补全已在 1.1 文档声明的 `HTMLTree` 薄包装。
- jsoup 更新为 1.23.1。
- 用显式 `Asset` 扩展确保 Java JAR 被 `PacletBuild` 收入归档。
- 以 Wolfram 15.0/Linux 的 fresh-kernel 安装测试作为主要验收。

## Evidence / 已验证证据

- 上游 #4 尚未完成：元数据要求 `Kernel/jsoupLink.wl`，原分支实际为根目录 `jSoupLink.wl`。
- 上游 #5 的依赖修复已进入 1.1（jsoup 1.17.2），但未发布。
- 本机 15.0 中，PR #8 的 `PacletBuild` 会遗漏仅由 `{"JLink"}` 声明的 `Java/` 文件；最小探针验证显式 `Asset` 能进入 manifest 和 `.paclet`。
- 真实用户 Paclet 仓库残留一个未被 `PacletFind` 识别的残缺目录：`/home/yode/.Wolfram/Paclets/Repository/jsoupLink-1.1.0`；自动测试不得依赖或覆盖它。
- 32 项 MUnit 全部通过；覆盖旧属性式 API、8 个辅助函数及 operator form、`HTMLTree`、Import/Export、mutation、DeepCopy 和 `:containsData(fkey)`。
- CodeInspector 返回 41 条 Warning/Remark，Fatal/Error 为 0；`Global`HTMLElement` 警告是为兼容旧代码而保留。
- 11 个文档 notebook 无模板占位并通过 Wolfram kernel 完整语法解析；FrontEnd 可逐页打开。
- `scripts/build.wls` 返回 0；最终归档为 `build/jsoupLink-1.1.0.paclet`，SHA-256 `8d1028548b35c4fd995029982bd7ca42e68758605baad6146e485c99edfe21d0`。
- 空用户仓库安装 1.1.0、官方 1.0.0 升级到 1.1.0 两条隔离路径均通过，解析入口精确指向 1.1.0。
- Wolfram 15.0 Linux FrontEnd 在文档操作完成后的退出阶段偶发 SIGSEGV；不影响构建脚本退出码、归档完整性或 fresh-kernel 安装验证。
- fork：`https://github.com/Juddd/jSoupLink`；Release：`https://github.com/Juddd/jSoupLink/releases/tag/1.1.0`。
- GitHub 重新下载的 Release 资产通过 `.sha256` 校验；远端 digest 与本地计算均为 `8d1028548b35c4fd995029982bd7ca42e68758605baad6146e485c99edfe21d0`，`.paclet` 大小为 683533 bytes。
- 远端 `master`、`maint/1.1.0` 和 tag `1.1.0` 在发布时均指向 `02b28f3f15cf0f6e438cd9d04fe87d0c33c507ee`；tag 保持在发布提交，后续状态记录作为 tag 后 bookkeeping。

## Next / 下一步

- 发布目标已完成；如继续维护，从 tag `1.1.0` 之后的新版本分支开始。

## Blockers / 阻塞项

- 暂无。
