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

## [LRN-20260813-003] best_practice

**Logged**: 2026-08-13T13:25:00+08:00
**Priority**: high
**Status**: superseded
**Area**: frontend

### Summary / 摘要

Wolfram 原生 `InputField` 不应被会随搜索状态更新的外层 `Dynamic` 或 `EventHandler` 重建，普通字母导航也不应注册为 notebook 全局按键；交互窗口入口还必须避免自动部署整个 notebook。

### Details / 详情

用户实测发现搜索框无法正常使用剪贴板，并且 `n`、`p` 不能作为查询文本输入。输入框曾被外层事件处理与跟踪 `root` 状态的动态表达式包裹，而搜索提交后又为 notebook 注册了全局 `KeyDown` 的 `n`、`p` 导航；移除这些事件后问题仍存在。进一步核对发现公开 `"DOMTree"` 入口绕过了已有 `popup`，使用会自动部署整个 notebook 的 `CreateDialog`。搜索后节点无法展开还暴露了动态重绘生成的 `Opener` 位于整体 `Deploy` 内，直接调用 setter 的测试无法覆盖真实 FrontEnd 点击。

### Suggested Action / 建议

搜索框使用裸 `InputField`，仅由独立显示变量控制创建；搜索、上一项和下一项使用显式按钮，不拦截 `ReturnKeyDown` 或普通字符键。公开入口使用显式 `Deployed -> False` 的 `CreateDocument`，动态 DOM 行不整体包裹 `Deploy`。这些是必要条件，但用户后续实测证明并不足以解决剪贴板与搜索后展开问题，参见 LRN-20260813-004。

### Metadata

- Source: user_feedback
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/jsoupLink.wlt
- Tags: wolfram, frontend, inputfield, clipboard, keyboard-events

### Resolution

- **Resolved**: 2026-08-13T13:25:00+08:00
- **Notes**: 用户后续两轮真实 FrontEnd 验收均复现原故障，本条结论被 LRN-20260813-004 取代。

---

## [LRN-20260813-004] correction

**Logged**: 2026-08-13T17:10:00+08:00
**Priority**: critical
**Status**: resolved
**Area**: tests

### Summary / 摘要

直接调用 `Opener` 的动态 setter 不能验证真实鼠标交互，无头 FrontEnd 的输入变量或表达式结构也不能验证系统剪贴板交互。

### Details / 详情

此前测试从渲染表达式中提取 setter 并直接执行，状态和可见行数都正确，因此错误地将“搜索后 Opener 可交互”视为通过。该测试绕过了 MouseDown/MouseUp、控件在事件期间被外层 `Dynamic` 替换、焦点提交和 FrontEnd 控件路由。用户在真实 Wolfram 15/Linux FrontEnd 中连续复验仍无法展开节点，也仍无法在搜索框中复制、剪切或粘贴。

### Suggested Action / 建议

树控件的自动测试只能声明状态更新和重绘边界；真实鼠标/剪贴板必须通过能驱动实际 FrontEnd 的端到端反馈回路或明确的用户手工复验。当前本机 cua-driver 合成输入会触发 Wolfram Qt/X11 崩溃，因此禁止把 setter 调用或无头 Paste 当作替代证据。

### Metadata

- Source: user_feedback
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/jsoupLink.wlt, PROJECT_STATE.md
- Tags: wolfram, frontend, opener, clipboard, false-positive, testing
- See Also: LRN-20260813-003

### Resolution

- **Resolved**: 2026-08-13T17:10:00+08:00
- **Notes**: 已删除伪交互测试；候选实现以独立刷新令牌和 queued 三角按钮消除事件期整树替换，68/68 测试仅表述可验证边界，最终交互明确留给真实 FrontEnd 复验。

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
## [LRN-20260813-005] correction

**Logged**: 2026-08-13T18:20:00+08:00
**Priority**: critical
**Status**: resolved
**Area**: frontend

### Summary / 摘要

Wolfram 交互窗口应部署具体的 GUI 表达式，而不是部署整个 notebook 或完全取消部署：`Deploy@Panel[...]` 会阻止 DOM 内容形成普通 notebook 选区，同时保留其中 `InputField` 和 `Button` 的活动性。

### Details / 详情

为恢复搜索框剪贴板，窗口被设为 `Deployed -> False, Editable -> True, Selectable -> True`；用户随后确认剪贴板恢复，但截图和实测显示 DOM 区域会形成持续的浅蓝 FrontEnd 内容选区，鼠标事件无法到达展开按钮和节点 handler。本机 Wolfram 15 的 `Deploy` 文档明确说明一般编辑和选择会被禁止，而 `InputField`、`Button` 等控件仍然活动，并单独演示 deployed `InputField` 内文本仍可选择和编辑。

无输入 FrontEnd 对照探针进一步验证：普通 `Panel` 的内部文本可被 `NotebookFind` 选中并由 `NotebookRead` 读回；`Deploy@Panel` 对相同内部选择返回 `$Failed`，同时实际 boxes 中仍存在 `InputFieldBox` 和 `ButtonBox`。

### Suggested Action / 建议

保持文档窗口本身 undeployed，以保留菜单、查找命令和正常输入环境；仅部署完整交互面板作为 GUI 边界。结构测试、选择对照和栅格探针覆盖部署语义，真实鼠标点击仍由用户在新内核中最终复验。

### Metadata

- Source: user_feedback
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/jsoupLink.wlt, PROJECT_STATE.md
- Tags: wolfram, frontend, deploy, selection, inputfield, button
- See Also: LRN-20260813-003, LRN-20260813-004

### Resolution

- **Resolved**: 2026-08-13T18:20:00+08:00
- **Notes**: 已使用 `Deploy@Panel[...]` 隔离 notebook 内容选择；68/68 MUnit、FrontEnd 选择对照、栅格探针、CodeInspector、构建及两条隔离安装路径通过，等待真实鼠标复验。

---
## [LRN-20260813-006] correction

**Logged**: 2026-08-13T18:35:00+08:00
**Priority**: critical
**Status**: resolved
**Area**: frontend

### Summary / 摘要

`Deploy@Panel` 修复了 notebook 浅蓝选区、剪贴板和节点选择，但不能据此推断异步 DOM `Dynamic` 内的 queued 三角按钮也已恢复。

### Details / 详情

用户对新候选包逐项复验后确认，另外三个问题均已修复，唯一剩余问题是其他节点的三角按钮仍无法展开或折叠。此前 FrontEnd 探针只证明按钮 box 被渲染、DOM 内容不可形成普通 notebook 选区，以及底层状态函数可直接调用；它没有触发真实三角按钮的 `ButtonFunction`。

### Suggested Action / 建议

直接提取并执行自制 `Button` action 后，真实节点状态和单次刷新均正确，因此排除局部变量闭包和底层 setter，剩余边界是自制小按钮的 FrontEnd 命中或调度。恢复上游原生 `Opener[Dynamic[..., setter]]`，保留集中行列表、显式 `treeRevision` 刷新、窗口部署、输入框和节点选择逻辑。

### Metadata

- Source: user_feedback
- Related Files: jsoupLink/Kernel/jsoupLink.wl, Tests/jsoupLink.wlt, PROJECT_STATE.md
- Tags: wolfram, frontend, button, queued, dynamic, false-positive
- See Also: LRN-20260813-004, LRN-20260813-005

### Resolution / 处理状态

- **Candidate Fixed**: 2026-08-13T19:47:26+08:00
- **Resolved**: 2026-08-14
- **Notes**: 结构探针确认当前输出含原生 `OpenerBox` 且不再含自制 disclosure `ButtonBox`；setter 打开/关闭与单次刷新、部署面板控件结构和浅黄色栅格探针通过。用户随后在真实 Wolfram 15.0/Linux FrontEnd 中确认，搜索后其他节点的原生三角按钮可以正常展开和折叠。

---
