# PROJECT_STATE

## 1.1.2 Maintenance / 当前维护版本

- 当前分支：`maint/1.1.2`，基线为已发布的 1.1.1 提交 `1e5dfb1`；1.1.2 已提交、推送并发布。
- 已修复 `Unwrap` 零参数调用和 `Clean` 的 jsoup 1.23.1 调用，后者使用 ``Safelist`relaxed[]``。
- 已新增属性式 `SelectFirst`、`ExpectFirst`、`Closest`、`SelectXPath`、`WholeText`、`WholeOwnText`、`Dataset`、`CSSSelector`，以及对应的 `HTML*` 薄包装；选择类包装支持 operator form。
- 已补充 `WholeOwnText` 属性和 `HTMLWholeOwnText` 薄包装，用于保留空白地读取元素直接文本。
- `Tests/jsoupLink.wlt` 当前为 93 项，WolframKernel 和 WolframAI TestReport 均为 93/93 通过；新增测试覆盖空匹配、ExpectFirst 异常、XPath、文本空白、dataset 键转换、Unwrap、Clean 和所有包装形式。
- `build/jsoupLink-1.1.2.paclet` 已生成，SHA-256 为 `02f658a81aac11e9223906b10372cdbd5c0c03b12327ecf432ea4d632e0c356a`；归档内容、源码哈希、JAR 哈希和旧入口排除检查通过。
- 两条隔离路径已通过：空用户库直接安装 1.1.2；官方 1.0.0 安装后升级到 1.1.2。CodeInspector 对主内核文件无 Fatal/Error，剩余提示为既有 `Global\`HTMLElement`` 兼容设计和原作者代码风格警告。
- 实现提交为 `a81ad01e906e30c40188824a084d9df51eb28be6`，已推送 `origin/maint/1.1.2`；annotated tag `1.1.2` 已推送并指向该实现提交。
- GitHub Release 已发布：`https://github.com/Juddd/jSoupLink/releases/tag/1.1.2`。GitHub MCP 回读确认正式、非草稿、非预发布；`.paclet` 资产为 686099 bytes，digest 为 `sha256:02f658a81aac11e9223906b10372cdbd5c0c03b12327ecf432ea4d632e0c356a`，`.sha256` 校验资产也已上传。
- `PacletBuild` 在生成归档后偶发 Wolfram FrontEnd 退出阶段 SIGSEGV；归档已生成且独立 kernel/隔离验证通过，需在交付说明中保留这一环境性现象。

## Goal / 目标

在已发布的 1.1.1 维护基线上完成 `jsoupLink` 1.1.2：修复 `Unwrap`/`Clean`，补齐八项属性式 API 与薄包装，并通过回归、构建和隔离安装验证。

## Progress / 当前进度

- 基线：`d5a3456`（上游 `feature/rel1.1`）。
- 历史发布分支：`maint/1.1.1`；当前工作分支见上方 1.1.2 维护记录。
- 已 cherry-pick Felix Kasza 的 PR #8 构建提交并保留作者信息；入口已落在 `jsoupLink/Kernel/jsoupLink.wl`。
- 已完成 #4 的入口/元数据修复、锁定 #5、更新 jsoup、补全文档/许可证/测试和唯一构建入口。
- 已提交并发布到 `Juddd/jSoupLink`；1.1.0 tag 与 Release 均指向已验证的维护提交。
- README 已翻译为简体中文，并补充 1.1.0 更新概览、8 个上游便捷函数与旧属性 API 的对应关系，以及本 fork 补全 `HTMLTree` 的边界说明。
- 1.1.1 DOM 树搜索已实现：`Ctrl+F` 打开搜索框，点击 `Search` 按钮提交，点击 `next`/`prev` 按钮循环导航，显示当前序号与总数，并自动展开、选中和滚动到匹配项。
- FrontEnd 验收发现搜索虽能展开到目标，但目标不醒目；已修复为选中直接包含命中 TextNode 的最小 Element，并用浅黄色高亮该元素及其直接命中文本行，使 Copy node / Copy CSS selector 直接作用于当前结果。
- 搜索仍只在点击 `Search` 时执行；输入框改为 `ContinuousAction -> True`，仅用于实时保存输入文本，避免下一次鼠标点击同时承担输入提交和节点点击。输入、复制、剪切、粘贴本身不会触发 DOM 搜索。
- FrontEnd 长 DOM 验收发现固定估算 20 px 行高会累计滚动误差；已将渲染行高和滚动计算统一为同一个稳定值。
- FrontEnd 栅格探针发现独立 `Item` 的 `Background` 在原 `Column`/`Pane` 布局中并不绘制；已将固定高度 DOM 行改为单列零间距 `Grid` 的直接 `Item`，浅黄色现在覆盖当前最小 Element 的标签行和直接命中文本行。
- 用户已完成最终真实 FrontEnd 验收：搜索框剪贴板、浅蓝 notebook 内容选区、节点选择/取消选择均正常，搜索后其他节点的原生三角按钮也可以展开和折叠。
- DOM 树的重绘依赖已从整个 `root[...]` 状态收窄为独立 `treeRevision`，滚动位置、查询和结果计数不再触发整树替换，节点选择事件使用 queued 方法。
- 当前候选删除 12x12、`Appearance -> None` 的自制 disclosure `Button`，恢复上游长期使用的原生 `Opener[Dynamic[..., setter]]`；setter 仍通过 `setDOMTreeNodeOpen` 更新单个节点并请求一次显式重绘。
- 当前候选修复将搜索框显式设为可编辑、可选择并持续回写，移除 `FinishDynamic[]` 强制同步，同时不再覆盖 `WindowElements`，保留普通文档窗口的默认键盘命令环境；用户已确认真实剪贴板恢复。
- 本轮按 Wolfram 15 本机文档将整个交互 `Panel` 包入 `Deploy`：一般 notebook 编辑和内容选择被禁止，但 `InputField`、`Button` 等控件保持活动。窗口本身仍为 `Deployed -> False, Editable -> True, Selectable -> True`，因此菜单命令和输入框不受损。
- 当前候选已构建并通过两条隔离安装及用户真实鼠标验收。
- Paclet 元数据、README、BUILD 和隔离安装脚本已统一到 1.1.1；发布提交、维护分支、`master`、annotated tag 和 GitHub Release 均已完成。

## Decisions / 关键决定

- 保留旧属性式 API 和 `Global`HTMLElement`。
- 保留作者新增的 8 个辅助函数；补全已在 1.1 文档声明的 `HTMLTree` 薄包装。
- jsoup 更新为 1.23.1。
- 用显式 `Asset` 扩展确保 Java JAR 被 `PacletBuild` 收入归档。
- 以 Wolfram 15.0/Linux 的 fresh-kernel 安装测试作为主要验收。
- DOM 树搜索只匹配非空 TextNode，忽略大小写；同一父元素内的多个匹配文本节点合并为一个结果，不匹配属性和 DataNode。

## Evidence / 已验证证据

- 上游 #4 尚未完成：元数据要求 `Kernel/jsoupLink.wl`，原分支实际为根目录 `jSoupLink.wl`。
- 上游 #5 的依赖修复已进入 1.1（jsoup 1.17.2），但未发布。
- 本机 15.0 中，PR #8 的 `PacletBuild` 会遗漏仅由 `{"JLink"}` 声明的 `Java/` 文件；最小探针验证显式 `Asset` 能进入 manifest 和 `.paclet`。
- 真实用户 Paclet 仓库残留一个未被 `PacletFind` 识别的残缺目录：`/home/yode/.Wolfram/Paclets/Repository/jsoupLink-1.1.0`；自动测试不得依赖或覆盖它。
- 32 项 MUnit 全部通过；覆盖旧属性式 API、8 个辅助函数及 operator form、`HTMLTree`、Import/Export、mutation、DeepCopy 和 `:containsData(fkey)`。
- 1.1.1 源码回归为 68/68 通过；除搜索语义和高亮外，新增边界测试锁定输入框持续回写及编辑/选择样式、默认窗口命令环境、树只跟踪显式刷新令牌、原生 `Opener` 双向 setter 和单次刷新请求。上述测试不冒充真实剪贴板或鼠标端到端测试。
- 真实 FrontEnd 短行探针将最小 `<p id="first">` 标签行和 `Needle one` 文本行渲染为 `#fff8c4`，419x72 PNG 中有 27,963 个精确目标色像素。
- 真实 FrontEnd 长 DOM 探针使用 128 个可见行和 2196 px `ScrollPosition`；最终 200 px 高视口中可见 `<p id="target">` 与 `clinico-pathological` 两行浅黄色高亮，144 dpi PNG 中有 36,667 个精确目标色像素。
- 前一候选重跑短 DOM 探针得到 423x72 PNG 和 28,384 个精确 `#fff8c4` 像素；本轮部署后的完整面板探针仍渲染 `InputFieldBox`、`ButtonBox` 和 23,750 个目标色像素；长 DOM 仍为 128 个可见行、2196 px `ScrollPosition`，400 px 高图像中有 37,088 个目标色像素，高亮和滚动未回归。
- FrontEnd 选择对照探针中，普通 `Panel` 可被 `NotebookFind` 选入内部文本并由 `NotebookRead` 读回；相同的 `Deploy@Panel` 返回 `$Failed` 且内部选区读回 `{}`。这自动覆盖了本轮浅蓝 notebook 选区根因，但不冒充真实鼠标点击验收。
- 自制 disclosure `Button` 的 action 可被直接提取执行并正确展开节点，但用户真实鼠标点击仍失败，证明直接调用 action 是假阳性，问题位于控件的 FrontEnd 命中或调度边界。
- 当前原生 `Opener` 探针确认真实输出包含一个 `OpenerBox`、不再包含调用 `setDOMTreeNodeOpen` 的 disclosure `ButtonBox`；双向 setter 可打开和关闭真实节点，每次只请求一次重绘。部署面板的 FrontEnd 栅格化仍包含 `InputFieldBox`、普通 `ButtonBox`、`OpenerBox` 和 23,617 个精确浅黄色像素。这些结果不声称覆盖真实鼠标点击。
- 2026-08-14 用户在真实 Wolfram 15.0/Linux FrontEnd 中确认，搜索后其他节点的原生三角按钮可以正常展开和折叠；至此发布前交互验收全部通过。
- 无头 FrontEnd 无法将系统焦点交给临时 `InputField`，程序化 Paste 不会更新动态变量；因此剪贴板快捷键和鼠标点击仍需真实 FrontEnd 手工复验，不以无头结果或源码结构宣称通过。
- 前轮 MCP CodeInspector 返回 111 条 Warning 和 4 条 Remark；本轮本机 CodeInspector 对主包文件返回 38 条检查，Fatal/Error 为 0。现有提示主要来自兼容旧代码的定义和原作者命名。
- 11 个文档 notebook 无模板占位并通过 Wolfram kernel 完整语法解析；FrontEnd 可逐页打开。
- `scripts/build.wls` 返回 0；最终归档为 `build/jsoupLink-1.1.0.paclet`，SHA-256 `8d1028548b35c4fd995029982bd7ca42e68758605baad6146e485c99edfe21d0`。
- 空用户仓库安装 1.1.0、官方 1.0.0 升级到 1.1.0 两条隔离路径均通过，解析入口精确指向 1.1.0。
- 本轮默认 `scripts/build.wls` 和原始 kernel 的同脚本执行都停在 `DocumentationBuildNotebooksIncremental`，超过 6 分钟无文件级进展后中断，未将无归档结果计为成功。最终候选仍由官方 `PacletBuild` 生成，只将 `Documentation` build handler 改为用 `PacletTools` 自己的 `copyRelativeFiles` 复用已安装上一候选的同版文档构建缓存；本轮未修改文档源。manifest、`CreatePacletArchive`、JAR/源码哈希和禁用旧文件校验均保留。
- 当前 `build/jsoupLink-1.1.1.paclet` 大小 685,239 bytes，SHA-256 `7cb42da4c10e54faf7329749ea815a0906f99319c1a829ef25ab31ffc7edc125`。归档内主源码 SHA-256 与工作区一致，均为 `7c0c45eefc970d57b79afece25b07ff7cc5409c9a36fbe2ce68c026abf7c9b56`；11 个文档 notebook、6 个 SearchIndex 文件、3 个 Index 文件和 3 个 SpellIndex 文件均在归档中，解包后的 11/11 notebook 通过 kernel 完整语法解析。
- 空用户仓库安装 1.1.1、官方 1.0.0 升级到 1.1.1 两条隔离路径均通过，fresh kernel 解析入口、旧 API 和内置 jsoup JAR 校验通过。
- Wolfram 15.0 Linux FrontEnd 在文档操作完成后的退出阶段偶发 SIGSEGV；不影响构建脚本退出码、归档完整性或 fresh-kernel 安装验证。
- 本轮 cua-driver 合成键鼠触发 Wolfram 15.0 Qt/X11 输入设备路径 SIGSEGV，GNOME Shell 也持续报告合成事件缺少有效 `GdkDevice`；因此停止 GUI 输入注入，交互式 `Ctrl+F`、剪贴板和按钮最终手工复验仍需用户完成，颜色和长 DOM 滚动已由无输入 FrontEnd 栅格探针验证。
- fork：`https://github.com/Juddd/jSoupLink`；Release：`https://github.com/Juddd/jSoupLink/releases/tag/1.1.0`。
- GitHub 重新下载的 Release 资产通过 `.sha256` 校验；远端 digest 与本地计算均为 `8d1028548b35c4fd995029982bd7ca42e68758605baad6146e485c99edfe21d0`，`.paclet` 大小为 683533 bytes。
- 远端 `master`、`maint/1.1.0` 和 tag `1.1.0` 在发布时均指向 `02b28f3f15cf0f6e438cd9d04fe87d0c33c507ee`；tag 保持在发布提交，后续状态记录作为 tag 后 bookkeeping。
- 1.1.1 发布提交为 `e889732eaf2a5587ea203ac6ad949860b062db36`；发布时远端 `master`、`maint/1.1.1` 和 tag `1.1.1` 均解析到该提交，tag 保持在发布提交，后续状态记录作为 tag 后 bookkeeping。
- GitHub Release：`https://github.com/Juddd/jSoupLink/releases/tag/1.1.1`，为正式、非草稿、非预发布且当前 latest release。两个资产均已通过 GitHub MCP 回读：paclet 为 685,239 bytes，服务器 digest 为 `sha256:7cb42da4c10e54faf7329749ea815a0906f99319c1a829ef25ab31ffc7edc125`；校验文件为 89 bytes。
- 从 GitHub 重新下载 `jsoupLink-1.1.1.paclet` 和 `.sha256` 到独立临时目录后，`sha256sum -c` 通过，下载文件的 SHA-256 与本地候选和服务器 digest 完全一致。

## Next / 下一步

- 1.1.1 发布目标已完成；后续维护从 tag `1.1.1` 之后的新版本分支开始。

## Blockers / 阻塞项

- 暂无。
