# PROJECT_STATE

## Goal / 目标

在上游 `feature/rel1.1` 基础上完成并发布可在 Wolfram 15.0/Linux 正常安装使用的 `jsoupLink` 1.1.0，不新增既定范围外的功能。

## Progress / 当前进度

- 基线：`d5a3456`（上游 `feature/rel1.1`）。
- 当前分支：`maint/1.1.0`。
- 已 cherry-pick Felix Kasza 的 PR #8 构建提交并保留作者信息；入口已落在 `jsoupLink/Kernel/jsoupLink.wl`。
- 已完成 #4 的入口/元数据修复、锁定 #5、更新 jsoup、补全文档/许可证/测试和唯一构建入口。
- 待完成：提交本地完善改动并发布到 `Juddd/jSoupLink`。

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

## Next / 下一步

1. 提交当前完善改动。
2. 创建 `Juddd/jSoupLink` fork，将上游远端命名为 `upstream`、fork 命名为 `origin`。
3. 推送维护分支，创建 tag `1.1.0` 和带 `.paclet`/SHA-256 的 GitHub Release。

## Blockers / 阻塞项

- 暂无。
