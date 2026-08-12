# Errors

## [ERR-20260812-015] Git query from release download directory

**Logged**: 2026-08-12T17:25:00+08:00
**Priority**: low
**Status**: resolved
**Area**: infra

### Summary / 摘要

远端资产校验命令切换到临时下载目录后，末尾继续运行 `git ls-remote origin`，因该目录不属于仓库而失败。

### Error

```text
fatal: 'origin' does not appear to be a git repository
```

### Context / 背景

- 此前的 Release 下载、SHA-256 和资产状态核验均已成功。
- 失败只影响同一组合命令末尾的 tag target 查询。

### Suggested Fix / 修复

回到项目工作目录单独运行 `git ls-remote origin 'refs/tags/1.1.0^{}'`，再与本地 `git rev-parse '1.1.0^{}'` 比较。

### Metadata

- Reproducible: yes
- Related Files: .git/config

### Resolution

- **Resolved**: 2026-08-12T17:25:00+08:00
- **Notes**: 已在仓库目录重跑；远端和本地 tag target 均为 `02b28f3f15cf0f6e438cd9d04fe87d0c33c507ee`。

---

## [ERR-20260812-014] Release checksum working directory

**Logged**: 2026-08-12T17:20:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: infra

### Summary / 摘要

Release 创建前从仓库根运行 `sha256sum -c build/jsoupLink-1.1.0.paclet.sha256`，而校验文件记录资产 basename，导致本地预检找不到文件；同一 shell 未启用 `set -e`，Release 随后仍创建成功。

### Error

```text
sha256sum: jsoupLink-1.1.0.paclet: No such file or directory
```

### Context / 背景

- Release URL 已返回，需独立核验远端资产而不能仅依赖本地源文件。
- 正确的本地校验应在 `build/` 目录运行。

### Suggested Fix / 修复

从 GitHub Release 下载 `.paclet` 和 `.sha256` 到全新临时目录，在该目录运行 `sha256sum -c`，并核对 Release 状态、资产大小和 tag target。

### Metadata

- Reproducible: yes
- Related Files: build/jsoupLink-1.1.0.paclet.sha256

### Resolution

- **Resolved**: 2026-08-12T17:25:00+08:00
- **Notes**: 从 GitHub Release 将两个资产重新下载到独立临时目录并成功执行 `sha256sum -c`；GitHub digest、本地重算和校验文件三者一致。

---

## [ERR-20260812-013] gh repo fork boolean flag

**Logged**: 2026-08-12T17:10:00+08:00
**Priority**: low
**Status**: resolved
**Area**: infra

### Summary / 摘要

本机 GitHub CLI 不支持显式仓库参数与 `--remote=false` 的组合，fork 命令在执行前返回用法错误。

### Error

```text
the `--remote` flag is unsupported when a repository argument is provided
```

### Context / 背景

- `Juddd/jSoupLink` 尚未创建，现有远端没有被改写。
- 当前 CLI 帮助表明显式仓库 fork 时省略 `--remote` 即不会要求添加远端。

### Suggested Fix / 修复

使用 `gh repo fork cekdahl/jSoupLink --clone=false`，创建完成后由 Git 手工重命名和添加远端。

### Metadata

- Reproducible: yes
- Related Files: .git/config

### Resolution

- **Resolved**: 2026-08-12T17:10:00+08:00
- **Notes**: 改用本机 CLI 支持的参数组合。

---

## [ERR-20260812-001] MUnit context assertion

**Logged**: 2026-08-12T14:03:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

首轮测试错误地将表达式 `Head[dom]` 直接传给具有保持语义的 `Context`。

### Error

```text
Context::ssle: The argument Context[Head[dom]] should be a symbol or a string.
```

### Context / 背景

- 目标是验证 HTMLDOM 对象头仍为 `Global`HTMLElement`。
- 包本身行为正确，失败来自测试表达式。

### Suggested Fix / 修复

直接断言 `Head[dom] === Global`HTMLElement`，避免用 `Context` 间接检查。

### Metadata

- Reproducible: yes
- Related Files: Tests/jsoupLink.wlt

### Resolution

- **Resolved**: 2026-08-12T14:03:00+08:00
- **Notes**: 已改为直接比较符号。

---

## [ERR-20260812-012] Wolfram FrontEnd exit SIGSEGV

**Logged**: 2026-08-12T16:45:00+08:00
**Priority**: medium
**Status**: wont_fix
**Area**: infra

### Summary / 摘要

Wolfram 15.0 Linux FrontEnd 在 headless 文档操作完成后的退出阶段偶发 SIGSEGV。

### Error

```text
The Wolfram FrontEnd has received the signal: SIGSEGV and has exited.
```

### Context / 背景

- 11 个 notebook 已在崩溃前全部完成 kernel 解析、FrontEnd 打开和关闭，随后才打印 `Validated 11 documentation notebooks.`。
- `PacletBuild` 的文档与搜索索引已完整进入归档；最终构建进程可靠返回 0。
- 该问题发生在 Wolfram FrontEnd 15.0 的退出路径，不在 jsoupLink 代码中。

### Suggested Fix / 修复

保留 kernel 语法解析、归档内容和 fresh-kernel 安装作为自动验收；记录 FrontEnd 退出崩溃但不将其误判为 paclet 构建失败。

### Metadata

- Reproducible: intermittent
- Related Files: jsoupLink/Documentation/English, scripts/build.wls

### Resolution

- **Resolved**: 2026-08-12T16:45:00+08:00
- **Notes**: 外部 Wolfram 15.0 Linux FrontEnd 缺陷，本项目不修改；以完成点之前的验证证据和构建退出码区分结果。

---

## [ERR-20260812-011] Temp cleanup command rejected

**Logged**: 2026-08-12T16:25:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

带递归删除 `trap` 的临时隔离复现命令被执行环境在进程创建前拒绝。

### Error

```text
rejected: rm -f style commands are not permitted. Use a safer approach
```

### Context / 背景

- 命令未实际启动，未创建临时目录或修改仓库。
- 目标是复现 Paclet 1.0.0 到 1.1.0 的版本选择。

### Suggested Fix / 修复

先单独解析 `mktemp -d` 返回的精确路径，复现结束后用 Wolfram `DeleteDirectory[..., DeleteContents -> True]` 清理明确目标。

### Metadata

- Reproducible: yes
- Related Files: scripts/test-isolated-install.sh

### Resolution

- **Resolved**: 2026-08-12T16:25:00+08:00
- **Notes**: 已改用分步创建、执行和精确清理。

---

## [ERR-20260812-010] Upgrade verifier assumes one installed version

**Logged**: 2026-08-12T16:20:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

官方 1.0.0 与新 1.1.0 均安装成功后，隔离验证器因 `PacletFind["jsoupLink"]` 不满足“恰好一个 1.1.0”而失败。

### Error

```text
Installed official 1.0.0 baseline.
Installed jsoupLink 1.1.0
PacletFind did not select exactly one 1.1.0 paclet.
```

### Context / 背景

- fresh 1.1.0 安装路径已完整通过。
- 需区分 Paclet 合法并列保留旧版与真实的版本选择错误。

### Suggested Fix / 修复

在保留的临时 userbase 中打印 `PacletFind` 的全部版本、位置、解析结果和 `$InputFileName`，再据实际选择语义调整验证器或包。

### Metadata

- Reproducible: yes
- Related Files: scripts/isolated-verify.wls, scripts/test-isolated-install.sh

### Resolution

- **Resolved**: 2026-08-12T16:35:00+08:00
- **Notes**: 复现确认 `PacletFind` 合法并列返回 1.1.0 和 1.0.0，但 `FindFile["jsoupLink`"]` 在 `Needs` 前后都选择 1.1.0。验证器现要求恰有一份 1.1.0，并断言解析入口来自该版本，不再要求旧版本被删除。

---

## [ERR-20260812-009] CodeInspector relative File

**Logged**: 2026-08-12T16:10:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

`CodeInspector`CodeInspect[File["relative/path"]]` 将相对文件名交给 `FindFile`，返回 `Failure["FindFileFailed", ...]`。

### Error

```text
Failure["FindFileFailed", <|"FileName" -> "jsoupLink/Kernel/jsoupLink.wl"|>]
```

### Context / 背景

- 文件在当前工作目录下真实存在。
- 静态检查命令必须显式识别 `Failure`，不能把它当作零问题。

### Suggested Fix / 修复

传入绝对 `File[...]`，并断言返回值是 inspection 列表而不是 `Failure`。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Kernel/jsoupLink.wl

### Resolution

- **Resolved**: 2026-08-12T16:35:00+08:00
- **Notes**: 改用绝对 `File[...]` 并断言非 `Failure`；检查得到 41 条 Warning/Remark，Fatal/Error 为 0。

---

## [ERR-20260812-008] TestReport exit assertion property

**Logged**: 2026-08-12T16:00:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

全量 MUnit 报告中 32 项均为 Success，但 shell 包装器用不存在的计数属性判断退出码，导致命令返回 1。

### Error

```text
TestsSucceededKeys contains 32 entries and all failure key sets are empty, but the wrapper exited 1.
```

### Context / 背景

- 包测试本身全部通过。
- 错误只在临时验收命令的 `report["TestsSucceeded"] === 32` 条件。

### Suggested Fix / 修复

从 `Normal[TestReport[...]]` 的 `TestsSucceededKeys` 和失败键集合计算准确计数。

### Metadata

- Reproducible: yes
- Related Files: Tests/jsoupLink.wlt, BUILD.md

### Resolution

- **Resolved**: 2026-08-12T16:35:00+08:00
- **Notes**: 直接读取报告对象的 `TestsSucceededKeys` 与三个失败键属性；最终为 32 项成功、0 项失败或跳过。

---

## [ERR-20260812-007] Notebook text validator failure

**Logged**: 2026-08-12T15:45:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: docs

### Summary / 摘要

首版文档验证器用 `ToExpression[Import[file, "Text"], InputForm, HoldComplete]` 检查完整 `.nb` 源码时，在首个 Guide 上失败。

### Error

```text
Kernel parse failed: .../Guides/jsoupLinkSymbols.nb
```

### Context / 背景

- `.nb` 文件包含 notebook 表达式以及文件尾缓存注释。
- 失败可能来自验证入口本身，也可能来自边界删除后的语法问题；尚未下结论。

### Suggested Fix / 修复

打印实际解析结果和消息，对比结构几乎未改的 notebook，并以 FrontEnd 只读打开作为独立判据。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Documentation/English

### Resolution

- **Resolved**: 2026-08-12T15:50:00+08:00
- **Notes**: `.nb` 完整源码会解析为包含 `Null` 与一个 `Notebook[...]` 的保持表达式；验证器改为要求完整解析成功且恰含一个 notebook，并独立用 FrontEnd 只读打开。

---

## [ERR-20260812-006] Notebook patch context mismatch

**Logged**: 2026-08-12T15:35:00+08:00
**Priority**: low
**Status**: resolved
**Area**: docs

### Summary / 摘要

包含 notebook 转义字符串的大型组合补丁因上下文不精确而原子失败。

### Error

```text
apply_patch verification failed: Failed to find expected lines in HTMLTree.nb
```

### Context / 背景

- 补丁同时覆盖多个 notebook 和一个较大的 See Also 动态盒单元。
- `\"` 转义文本与补丁上下文不一致；补丁原子失败，未留下部分修改。

### Suggested Fix / 修复

普通说明使用小型精确补丁；大型 notebook 单元继续使用已验证的配平边界整体替换。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Documentation/English/ReferencePages/Symbols/HTMLTree.nb

### Resolution

- **Resolved**: 2026-08-12T15:35:00+08:00
- **Notes**: 已拆分编辑策略，避免依赖大段转义上下文。

---

## [ERR-20260812-005] Overbroad notebook string replacement

**Logged**: 2026-08-12T15:25:00+08:00
**Priority**: high
**Status**: resolved
**Area**: docs

### Summary / 摘要

首版 notebook 清理脚本对表达式中的所有字符串使用替换规则，误触 FrontEnd 动态盒和 UUID 等内部结构，产生大范围无关改写。

### Error

```text
StringReplace[...] remained inside DynamicModuleBox and other box structures.
11 notebooks changed by thousands of unrelated lines.
```

### Context / 背景

- 目标改动仅为移除空模板单元、补关键词与少量说明。
- 保存后的源码仍有 `HTMLTree.nb` 的 `XXXX`，且 diff 明显超过预期。
- 文档目录在本轮操作前已确认没有未提交修改，因此可以精确撤回本轮生成内容。

### Suggested Fix / 修复

恢复本轮文档改动后，改用保留原始文本的配平边界编辑，只修改完整目标 `Cell` 或 `CellGroupData`，并以最小 diff、占位符扫描和 notebook 解析作为验收。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Documentation/English

### Resolution

- **Resolved**: 2026-08-12T15:50:00+08:00
- **Notes**: 精确恢复首次生成内容，改用配平方括号的完整单元边界编辑；最终 diff 保留原始 UUID 和缓存结构。

---

## [ERR-20260812-004] Headless NotebookOpen

**Logged**: 2026-08-12T15:15:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: docs

### Summary / 摘要

原始 `WolframKernel -script` 中直接调用 `NotebookOpen` 无法读取文档 notebook，因为该 kernel 没有 FrontEnd。

### Error

```text
FrontEndObject::notavail: A front end is not available; certain operations require a front end.
Could not open .../jsoupLinkSymbols.nb
```

### Context / 背景

- 目标是按 notebook 表达式安全清理 DocumentationTools 模板占位。
- 失败发生在打开第一个文件时，文档源码没有被写入。

### Suggested Fix / 修复

使用本机 Wolfram 提供的 FrontEnd 会话包装整个 notebook 打开、变换和保存过程。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Documentation/English

### Resolution

- **Resolved**: 2026-08-12T15:50:00+08:00
- **Notes**: notebook 验证流程改用 `UsingFrontEnd` 包装只读打开与关闭。

---

## [ERR-20260812-003] WolframKernel script arguments

**Logged**: 2026-08-12T15:00:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

`WolframKernel -script file.wls archive.paclet` 中 `$ScriptCommandLine` 为空，隔离安装脚本无法取得归档参数。

### Error

```text
Rest::norest: Cannot take Rest of expression {} with length zero.
Archive not found.
```

### Context / 背景

- `scripts/test-isolated-install.sh` 使用原始 `WolframKernel -noinit -noprompt -script`。
- `isolated-smoke.wls` 和 `install-official-1.0.wls` 错误地从 `$ScriptCommandLine` 取参数。

### Suggested Fix / 修复

用最小探针确认 Wolfram 15.0 的 `$CommandLine` 结构，再由原始 kernel 的实际参数列表解析 `.paclet` 路径。

### Metadata

- Reproducible: yes
- Related Files: scripts/test-isolated-install.sh, scripts/isolated-smoke.wls, scripts/install-official-1.0.wls

### Resolution

- **Resolved**: 2026-08-12T15:05:00+08:00
- **Notes**: 最小探针确认原始 `WolframKernel -script` 将完整参数放入 `$CommandLine`，而 `$ScriptCommandLine` 仅由 `wolframscript` 设置；两处脚本改为从 `$CommandLine` 选取 `.paclet` 参数。

---

## [ERR-20260812-002] apply_patch binary deletion

**Logged**: 2026-08-12T14:10:00+08:00
**Priority**: low
**Status**: resolved
**Area**: docs

### Summary / 摘要

`apply_patch` 无法删除 PR #8 中的二进制 PNG。

### Error

```text
apply_patch verification failed: invalid utf-8 sequence
```

### Context / 背景

- 要删除的是已不再被新构建文档引用的 `successobject.png`。
- 整个补丁原子失败，没有留下部分修改。

### Suggested Fix / 修复

文本文件继续使用 `apply_patch`；二进制跟踪文件使用 `git rm` 删除。

### Metadata

- Reproducible: yes
- Related Files: successobject.png

### Resolution

- **Resolved**: 2026-08-12T14:10:00+08:00
- **Notes**: 已拆分文本补丁与二进制删除操作。

---
