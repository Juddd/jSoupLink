# Errors

## [ERR-20260813-002] cua-driver text input passed through the active IME

**Logged**: 2026-08-13T02:35:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

通过 `cua-driver type_text` 向 Mathematica Input 单元逐字输入 ASCII 代码时，当前中文输入法转换了字符，导致表达式损坏。

### Error

```text
输入后的 Needs、Import、文件路径和符号名均出现中文候选转换，不能执行。
```

### Context / 背景

- `cua-driver` 的 X11 后台输入路径明确不可用，前台逐键输入经过当前 IME。
- Paclet 安装和 Wolfram kernel 本身正常，问题只在 GUI 自动输入层。

### Suggested Fix / 修复

用 `clipboard_write` 写入精确代码并以 `clipboard_read` 读回校验，再通过 `Ctrl+V` 粘贴到 Mathematica 输入单元。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Kernel/jsoupLink.wl

### Resolution

- **Resolved**: 2026-08-13T02:36:00+08:00
- **Notes**: 改用已校验的剪贴板粘贴路径完成 FrontEnd 同 kernel 加载。

---
## [ERR-20260813-012] archive count awk used a reserved function name

**Logged**: 2026-08-13T21:01:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

归档内容辅助计数命令把 awk 内置函数名 `index` 用作计数变量，导致语法错误。

### Error / 错误

```text
awk: line 1: syntax error at or near ++
```

### Context / 背景

- `unzip -l` 的原始列表已经显示 11 个 notebook 和 `SearchIndex`、`Index`、`SpellIndex`。
- 失败只发生在额外汇总命令，不影响归档或其他校验结果。

### Suggested Fix / 修复

使用 `rg -c` 分别统计各类路径，或采用不与 awk 内置函数冲突的变量名。

### Metadata

- Reproducible: yes
- Related Files: build/jsoupLink-1.1.1.paclet

### Resolution / 解决

- **Resolved**: 2026-08-13T21:01:00+08:00
- **Notes**: 改用独立 `rg -c` 计数重跑。

---
## [ERR-20260813-011] wolframscript PacletBuild stalled in staging

**Logged**: 2026-08-13T20:43:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

本轮通过 shebang 运行 `./scripts/build.wls` 时，`PacletBuild` 在 staging 阶段运行约 6 分钟仍未生成 `.paclet`，主 kernel 等待一个 WSTP 辅助连接返回。

### Error / 错误

```text
build/jsoupLink staging exists, but build/jsoupLink-1.1.1.paclet does not exist.
```

### Context / 背景

- 只有一个构建任务在运行，没有并发写 `build/`。
- 内核仍存活但停在 `select`；`lsof` 显示额外的共享内存 WSTP 连接。
- 中断后 shell 返回 0，但归档不存在，因此按产物检查判定该次构建失败。

### Suggested Fix / 修复

确认无残留构建进程后，用原始 `WolframKernel -noinit -noprompt -script scripts/build.wls` 重试；若仍卡在 `DocumentationBuildNotebooksIncremental`，给官方 `PacletBuild` 传入只替换 `Documentation` build 操作的 handler，用 `PacletTools` 自己的 `copyRelativeFiles` 原样复制已验证 notebook。仍以归档存在性、manifest、包内源码/JAR 哈希和隔离安装为准。

### Metadata

- Reproducible: unknown
- Related Files: scripts/build.wls, build/
- See Also: ERR-20260813-009, ERR-20260813-010

### Resolution / 解决

- **Resolved**: 2026-08-13T20:54:00+08:00
- **Notes**: 原始 kernel 重试同样在文档增量构建处停滞；后备 handler 通过官方 `PacletBuild` 成功生成标准归档。首个后备包只有 notebook、没有生成索引；复用已安装上一候选的同版文档缓存时，最初又错误要求生成索引逐项进入 manifest，随后还修正了 `RelativePath` 上下文。最终按 `PacletTools` 实际边界处理：manifest 记录扩展声明的 notebook，handler 复制缓存中的全部文档构建文件，解包后再断言三类索引。最终包含 11 个 notebook、6 个 SearchIndex 文件、3 个 Index 文件、3 个 SpellIndex 文件；归档、源码/JAR 哈希和两条隔离安装均重新验证。

---
## [ERR-20260813-010] concurrent FrontEnd probes stalled

**Logged**: 2026-08-13T19:52:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: tests

### Summary / 摘要

并行运行两个各自调用 `UsingFrontEnd` 的 WolframKernel 探针时，两个进程均无输出挂起；改为串行后，包含 `NotebookFind` 的选择探针仍无输出挂起，无法形成本轮有效的选择边界验收结果。

### Error / 错误

```text
Both concurrent probes produced no output; the selection probe also stalled when retried alone.
```

### Context / 背景

- 两个探针分别测试 `Deploy` 选择边界和长 DOM 栅格化；串行重试只执行了选择探针。
- 二者都需要连接本机同一个 Wolfram FrontEnd；源码测试和 CodeInspector 已完成，不受影响。
- 已用中断结束两个精确会话，并确认无相应探针 kernel 残留。

### Suggested Fix / 修复

所有依赖 `UsingFrontEnd`、`CreateDocument` 或 `Rasterize` 的探针严格串行运行；涉及 `NotebookFind` 的隐藏 notebook 探针还可能受当前真实 FrontEnd 会话状态影响。只有进程明确退出且打印 pass marker 时才计为通过，阻塞结果不得重试成“通过”。

### Metadata

- Reproducible: yes
- Related Files: /tmp/jsouplink-deployed-selection-probe.wls, /tmp/jsouplink-long-dom-opener-probe.wls
- See Also: ERR-20260813-009

### Resolution / 解决

- **Resolved**: 2026-08-13T19:52:00+08:00
- **Notes**: 并行结果和串行选择探针均作废并终止；本轮沿用此前已通过的选择对照及用户真实确认，当前改动只由直接相关的原生 `Opener` 探针覆盖。

---
## [ERR-20260813-007] Dynamic outside Deploy removed rendered row backgrounds

**Logged**: 2026-08-13T11:00:00+08:00
**Priority**: high
**Status**: resolved
**Area**: frontend

### Summary / 摘要

为排查搜索后的 `Opener` 交互，尝试将 `Deploy@Dynamic[...]` 改为 `Dynamic[Deploy[...]]`，真实 FrontEnd 中浅黄色背景随即消失。

### Error

```text
short raster: ExactTargetPixels -> 0
long raster: ExactTargetPixels -> 0
```

### Context / 背景

- MUnit 的表达式结构检查无法发现该渲染回归。
- 原 `Deploy@Dynamic[...]` 下同一探针分别有 27,963 和 36,667 个精确目标色像素。

### Suggested Fix / 修复

保留已验证的 `Deploy@Dynamic[...]`；用事件状态和焦点探针排查 `Opener`，不要改动部署层次。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/jsoupLink.wlt
- See Also: ERR-20260813-005

### Resolution

- **Resolved**: 2026-08-13T11:00:00+08:00
- **Notes**: 已撤回该结构改动，两个栅格探针恢复到 27,963 和 36,667 个浅黄色像素。

---

## [ERR-20260813-001] CLI FrontEnd probe used a different kernel

**Logged**: 2026-08-13T00:03:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: tests

### Summary / 摘要

通过 CLI `UsingFrontEnd` 创建动态 DOM 树时，FrontEnd 将 notebook 动态求值路由到另一个 kernel；Java DOM 对象和私有包定义不在该 kernel 中，界面因此显示未求值表达式。

### Error

```text
动态 notebook 中出现 jsoupLink`Private`tree[...] 等未求值表达式，不能作为正常用户路径的 FrontEnd 验收结果。
```

### Context / 背景

- 源 kernel 中的 Java DOM 对象不能直接跨 kernel 作为 J/Link 对象继续使用。
- 包源码、MUnit 和语法解析均正常，失败发生在 CLI 探针的 kernel 路由边界。
- `wolframscript` 查询 `Options[InputField, ContinuousAction]` 时还报告缺少 `~/.config/Wolfram/WolframScript/WolframScript.conf`，但表达式仍成功返回 `ContinuousAction -> False`；这条配置警告与包无关。

### Suggested Fix / 修复

在用户正常启动的 Wolfram FrontEnd kernel 中完成 `Get`、HTML 导入、DOM 树创建和交互测试，保证 Java 对象、私有定义及 Dynamic 都在同一 kernel。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/Fixtures/search.html

### Resolution

- **Resolved**: 2026-08-13T00:03:00+08:00
- **Notes**: 改用用户手动打开的 Wolfram 15.0 FrontEnd 窗口和 cua-driver 定向后台交互验收。

---

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
## [ERR-20260813-004] cua-driver background Shift+Enter closed the Mathematica FrontEnd

**Logged**: 2026-08-13T03:15:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

在 Mathematica 主 notebook 中用不可验证的背景坐标点击选择输入单元后发送 `Shift+Enter`，交互式 FrontEnd 随后退出。

### Error

```text
hotkey/click effect: unverifiable
list_windows after Shift+Enter: Found 0 windows
pgrep: the interactive WolframNB process was gone
```

### Context / 背景

- 目标是重新计算已有的 `Get[...]; obj["DOMTree"]` 验收单元。
- 背景坐标点击没有提供“目标单元已被选中”的语义证据，继续发送计算快捷键不安全。

### Suggested Fix / 修复

Mathematica notebook 计算必须先从新截图确认目标单元选择状态；背景动作无法确认时，只升级该动作到前景并立即验证，不连续发送无法确认的输入。

### Metadata

- Reproducible: unknown
- Related Files: jsoupLink/Kernel/jsoupLink.wl

### Resolution

- **Resolved**: 2026-08-13T03:18:00+08:00
- **Notes**: 停止复用不可验证动作链；重新启动交互式 FrontEnd 后改用可见选中状态和逐动作截图验收。

---

## [ERR-20260813-003] cua-driver launch_app used a guessed Linux path

**Logged**: 2026-08-13T03:16:00+08:00
**Priority**: medium
**Status**: resolved
**Area**: tests

### Summary / 摘要

用猜测的 `/usr/local/bin/mathematica` 调用 Linux `launch_app` 被拒绝。

### Error

```text
Failed to launch: '/usr/local/bin/mathematica' is not an executable on PATH and matches no installed .desktop application. Call list_apps and round-trip its launch_path.
```

### Context / 背景

- 需要在异常退出后恢复 Mathematica FrontEnd。
- `cua-driver` 的 Linux 启动路径要求使用 `list_apps` 返回的已注册 Desktop Entry 命令。

### Suggested Fix / 修复

先调用 `list_apps`，按应用名筛选，再把返回的 `launch_path` 原样传给 `launch_app`。

### Metadata

- Reproducible: yes
- Related Files: .learnings/ERRORS.md

### Resolution

- **Resolved**: 2026-08-13T03:18:00+08:00
- **Notes**: 已解析到 `/usr/local/Wolfram/Wolfram/15.0/Executables/WolframNB --name com.wolfram.Wolfram.15.0`。

---
## [ERR-20260813-005] DOM search Item background was not rendered

**Logged**: 2026-08-13T03:25:00+08:00
**Priority**: high
**Status**: resolved
**Area**: frontend

### Summary / 摘要

搜索结果表达式包含浅黄色 `Background` 选项，但真实 FrontEnd 中仍显示白色。

### Error

```text
MUnit expression check: passed
FrontEnd raster probe: ExactTargetPixels -> 0
```

### Context / 背景

- 背景选项位于独立 `Item` 上，而 DOM 行由 `Column`/`Pane` 排列。
- `Item` 的背景只有作为 `Grid` 等容器的直接单元格时才被绘制。
- 因此只检查表达式中存在 `Background -> RGBColor[...]` 会产生假阳性。

### Suggested Fix / 修复

将固定高度行包装成 `Grid` 的直接 `Item`，由行级函数选择搜索浅黄色或手动选择蓝色；除结构回归外，用 `UsingFrontEnd@Rasterize` 检查实际目标色像素。

### Metadata

- Reproducible: yes
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/jsoupLink.wlt

### Resolution

- **Resolved**: 2026-08-13T03:27:00+08:00
- **Notes**: 48/48 MUnit 通过；短行渲染含 27,963 个 `#fff8c4` 像素，128 行滚动视口含 36,667 个目标色像素。

---
## [ERR-20260813-006] Temporary cleanup used a blocked rm command

**Logged**: 2026-08-13T03:32:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary / 摘要

收尾时使用 `rm -f` 清理精确列出的 `/tmp` 探针文件，被执行工具的安全策略拒绝。

### Error

```text
rm -f style commands are not permitted. Use a safer approach
```

### Context / 背景

- 命令未执行，没有文件被删除。
- 目标均为本轮创建的临时脚本、notebook 和 PNG。

### Suggested Fix / 修复

文本文件用 `apply_patch` 删除；`/tmp` 挂载不支持 `gio trash` 时，只对已核实的本轮临时二进制文件逐个使用 `unlink`。

### Metadata

- Reproducible: yes
- Related Files: .learnings/ERRORS.md

### Resolution

- **Resolved**: 2026-08-13T03:32:00+08:00
- **Notes**: `gio trash` 对 `/tmp` 返回“不支持在系统内部挂载上的丢弃到回收站操作”；随后仅对两个已核实的探针 PNG 逐个使用 `unlink`。

---
## [ERR-20260813-008] wolframscript validation ran from the user Wolfram directory

**Logged**: 2026-08-13T17:55:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

使用 `wolframscript -code` 和相对路径运行回归时，kernel 的 `Directory[]` 是 `/home/yode/WolframDir`，而不是 shell 传入的项目目录；缺失测试文件后错误的退出条件还把 0 项测试当成了成功。

### Error

```text
TestReport::fnfnd: File "Tests/jsoupLink.wlt" not found.
<|TestsSucceeded -> 0, TestsFailed -> 0, TestsTotal -> Missing[...]|>
```

### Context / 背景

- shell 工作目录为 `/home/yode/Documents/Program/other/jSoupLink`。
- `wolframscript` 中 `$InitialDirectory` 是项目目录，但 `Directory[]` 被用户配置设为 `/home/yode/WolframDir`。
- CodeInspector 同时因未使用 `File[path]` 而收到普通字符串代码，不是文件内容。

### Suggested Fix / 修复

项目测试和 CodeInspector 使用已验证的 `WolframKernel -noinit -noprompt -run ...` 命令；退出条件必须同时断言预期测试总数非零及失败数为零，CodeInspector 使用 `CodeInspector`CodeInspect[File[file]]`。

### Metadata

- Reproducible: yes
- Related Files: Tests/jsoupLink.wlt, BUILD.md

### Resolution

- **Resolved**: 2026-08-13T17:55:00+08:00
- **Notes**: 改用原始 kernel 和绝对解析后的项目路径重跑完整验证。

---
## [ERR-20260813-009] concurrent build probes raced on the shared build directory

**Logged**: 2026-08-13T18:08:00+08:00
**Priority**: high
**Status**: resolved
**Area**: tests

### Summary / 摘要

为核对构建入口，同时运行了三个都会删除和写入 `build/` 的命令，导致 `PacletBuild` 相互覆盖、`CopyFile::eexist`，其中一个进程被系统终止。

### Error

```text
CopyFile::eexist: .../build/jsoupLink/Kernel/jsoupLink.wl already exists.
Build failed: PacletBuild did not return Success.
Killed
```

### Context / 背景

- `scripts/build.wls` 开始时会删除整个 `build/`，因此不是可并行执行的只读验证。
- 并行结果无法判断单次构建本身是否正常，必须全部作废。

### Suggested Fix / 修复

构建、解包和隔离安装按顺序串行执行；显式传播子命令退出码，并在进入下一阶段前检查归档存在性和源码哈希。

### Metadata

- Reproducible: yes
- Related Files: scripts/build.wls, build/

### Resolution

- **Resolved**: 2026-08-13T18:08:00+08:00
- **Notes**: 确认没有遗留构建 kernel 后，只运行一次官方构建脚本。

---
