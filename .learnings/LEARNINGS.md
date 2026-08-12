# Learnings

## [LRN-20260812-001] best_practice

**Logged**: 2026-08-12T13:46:00+08:00
**Priority**: high
**Status**: resolved
**Area**: infra

### Summary / 摘要

Wolfram 15.0 的 `PacletBuild` 返回 `Success` 不代表未被扩展声明覆盖的 JAR 已进入归档。

### Details / 详情

仅声明 `{"JLink"}` 时，`PacletExtensionFiles` 对该扩展返回 `Missing[NotAvailable]`，PR #8 构建出的归档遗漏 `Java/jsoup-1.17.2.jar`。通过显式 `Asset` 扩展声明 Java JAR 后，最小探针的 manifest 和归档均包含该文件。

### Suggested Action / 建议

构建脚本必须同时检查 `PacletManifest`、解包后的归档文件清单和 fresh-kernel Java 类加载结果。

### Metadata

- Source: investigation
- Related Files: jsoupLink/PacletInfo.wl, BUILD.md
- Tags: wolfram, pacletbuild, jlink, jar

### Resolution

- **Resolved**: 2026-08-12T17:00:00+08:00
- **Notes**: `PacletInfo.wl` 增加显式 `Asset`，构建脚本验证 manifest、解包归档和 JAR 哈希，隔离安装验证 fresh-kernel 类加载与解析。

---

## [LRN-20260812-002] best_practice

**Logged**: 2026-08-12T13:46:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

修改临时 `HOME` 不能隔离本机 Wolfram 用户目录，应使用 `WOLFRAM_USERBASE` 并显式处理许可证。

### Details / 详情

登录 shell 会恢复 `HOME`，而即便非登录 shell 修改 `HOME`，本机 `$UserBaseDirectory` 仍为 `/home/yode/.Wolfram`。官方 `WolframKernel` 文档指定 `WOLFRAM_USERBASE` 控制该目录；完全空的临时 userbase 同时缺少许可证文件，因此测试环境需要只读引用或复制现有许可证配置。

### Suggested Action / 建议

隔离安装测试使用临时 `WOLFRAM_USERBASE`、`WolframKernel -noinit`，并只在临时 userbase 中准备许可证入口。

### Metadata

- Source: investigation
- Related Files: Tests, BUILD.md
- Tags: wolfram, isolation, userbase, licensing

### Resolution

- **Resolved**: 2026-08-12T17:00:00+08:00
- **Notes**: 隔离脚本使用两个临时 `WOLFRAM_USERBASE`，从实际正常 `$UserBaseDirectory` 只读链接许可证，并验证 fresh install 与 1.0.0 升级路径。

---
