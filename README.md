# jsoupLink

原作者：[Calle Ekdahl](https://github.com/cekdahl)。

本项目依据 GPL-2.0-or-later 许可证发布。

当前版本：1.1.1

## 简介

[jsoup](https://jsoup.org/) 是一个使用 Java 编写的开源库，擅长解析 HTML 和操作 DOM。jsoupLink 是一个使用 Wolfram Language 编写的 Mathematica 包，旨在为 Mathematica 用户提供自然、易用的 jsoup 接口。

在传统做法中，Mathematica 通常将 HTML 导入为符号 XML，再通过模式匹配进行较为繁琐的变换。jsoupLink 则引入了 HTML 元素对象，使遍历和修改 DOM 树变得更加直接。

jsoupLink 最常见的用途是从网页中提取信息，例如表格数据。

## 1.1.1 更新

1.1.1 完成了上游 [#3](https://github.com/cekdahl/jSoupLink/issues/3) 所提出的 DOM 树文本搜索：

- 在 DOM 树窗口中按 `Ctrl+F` 打开搜索框，输入文本后点击右侧的 `Search` 按钮搜索。
- 搜索忽略大小写，并自动展开目标节点的祖先层级、选中直接包含匹配文本的最小元素节点、用浅黄色高亮该节点并滚动到目标文本附近；“Copy node”和“Copy CSS selector”会直接作用于这个节点。
- 搜索框右侧的 `next` 和 `prev` 按钮分别切换到下一个和上一个匹配；到达末尾或开头时会循环。
- 搜索框旁显示“当前序号 / 匹配总数”。
- 搜索只匹配页面中的文本节点，不匹配 HTML 属性、脚本等数据节点，也不会跨不同文本节点拼接关键字。
- 搜索框保留标准的复制、剪切和粘贴操作；搜索完成后仍可用鼠标继续展开或折叠任意 DOM 节点。

## 1.1.0 更新

1.1.0 在保留原有属性式 API 的基础上，补全了上游尚未完成的 1.1 分支：

- 上游 1.1 分支新增了 8 个便捷函数：`HTMLSelect`、`HTMLAttribute`、`HTMLAttributes`、`HTMLParent`、`HTMLChildren`、`HTMLSiblings`、`HTMLOwnText` 和 `HTMLAllText`。其中 `HTMLSelect` 与 `HTMLAttribute` 还支持操作符形式。
- 原有的 `element["Property"]` 属性式调用仍然可用；这些便捷函数只是对应属性调用的薄包装，不会破坏现有 notebook。
- 本 fork 补全了上游文档中已经声明、但源码中尚未实现的 `HTMLTree[element]`，它等价于 `element["DOMTree"]`。
- 修复了上游 [#4](https://github.com/cekdahl/jSoupLink/issues/4)：统一区分大小写的包入口和 Paclet 元数据，使 ``Needs["jsoupLink`"]`` 能在 Wolfram 15.0/Linux 上正确加载。
- 修复并通过回归测试锁定了上游 [#5](https://github.com/cekdahl/jSoupLink/issues/5) 涉及的 `:containsData(...)` 选择器行为。
- 内置 jsoup 已更新至 1.23.1，并确保 JAR、符号元数据和文档均被正确打入 Paclet。
- 为兼容旧代码，HTML 元素对象的头部仍保持为 ``Global`HTMLElement``。

## 安装 jsoupLink

jsoupLink 以 Paclet 形式发布。请从 [Releases 页面](https://github.com/Juddd/jSoupLink/releases)下载 1.1.1，然后执行：

```wl
PacletInstall["/path/to/jsoupLink-1.1.1.paclet"]
```

使用 `Needs` 加载 jsoupLink：

```wl
Needs["jsoupLink`"]
```

请注意，包上下文名称区分大小写。请使用上面的 ``Needs["jsoupLink`"]``，不要写成 ``Needs["jSoupLink`"]``。

## 导入和导出文档

jsoupLink 可以配合内置的 `Import` 和 `Export` 命令导入、导出 HTML，只需将文件格式指定为 `"HTMLDOM"`：

```wl
document = Import["/path/to/input.html", "HTMLDOM"];
Export["/path/to/output.html", document, "HTMLDOM"]
```

![Mathematica 图形](http://i.stack.imgur.com/5yVE6.png)

导入结果是一个 HTML 元素对象。它提供了一组属性，可以读取或修改自身及其子元素。修改对象后，可以同样方便地将其重新导出为 HTML：

![Mathematica 图形](http://i.stack.imgur.com/VclVR.png)

## HTML 元素

HTML 文档由嵌套元素组成。例如，`<div><p>Paragraph 1</p><p>Paragraph 2</p></div>` 包含一个 `div` 元素和两个 `p` 元素：`div` 是两个 `p` 的父元素，两个 `p` 互为兄弟元素。

jsoup 为每个元素提供一个对象，并通过属性表达对象之间的关系。对应 `div` 的对象，其 `"Children"` 属性会返回两个 `p` 对象；任一 `p` 对象的 `"Parent"` 属性会返回 `div` 对象；任一 `p` 对象的 `"Siblings"` 属性会返回另一个 `p` 对象。

其他属性可以读取元素的内容。例如，`div` 的 `"InnerHTML"` 属性返回字符串 `<p>Paragraph 1</p><p>Paragraph 2</p>`，而第一个 `p` 的 `"OuterHTML"` 属性返回 `<p>Paragraph 1</p>`。

jsoupLink 可以直接访问这些对象及其属性。在 notebook 中，HTML 元素对象拥有专门的摘要显示形式：

![Mathematica 图形](http://i.stack.imgur.com/JOSg4.png)

从最外层的 `html` 元素对象开始，可以通过各种属性找到其他感兴趣的元素。属性采用对象式调用，例如：

```wl
element["TagName"]
element["Attribute", "href"]
element["Select", "p.note"]
```

与普通 Wolfram Language 表达式不同，HTML 元素对象是可变对象。某些属性可以直接修改元素，例如：

```wl
element["Attribute", "key", "value"]
element["AddClass", "selected"]
```

设置属性时还可以使用简写形式 `element[key] = value`。如果 `attr` 不是 `element["Properties"]` 列出的内置属性，也可以使用 `element[attr]` 直接读取同名 HTML 属性。

## 属性参考

下文将表示 HTML 元素的对象简称为“元素”。元素按照 DOM 树组织；“同一层级”“最上层”和“下方”等描述均相对于这棵树而言。

所有元素都支持以下属性：

- `element["TagName"]`：返回标签名。例如，链接元素返回 `"a"`，段落元素返回 `"p"`。

- `element["TagName", "tag"]`：设置元素的标签名。例如，可将 `h1` 元素改为 `h2`。

- `element["Root"]`：返回最上层元素，通常为 `html`。

- `element["Parent"]`：返回 `element` 的直接父元素。例如，`body` 的父元素通常是 `html`。

- `element["Children"]`：返回直接位于 `element` 下方的所有子元素。例如，`li` 通常是 `ul` 的子元素。

- `element["Siblings"]`：返回与 `element` 位于同一层级的所有兄弟元素。例如，一个 `li` 的兄弟元素通常是其他 `li`。

- `element["Select", "selector"]`：返回 `element` 下方所有匹配 CSS 选择器的元素。选择器语法参见 [Use selector syntax to find elements](https://jsoup.org/cookbook/extracting-data/selector-syntax)。

- `element["AllElements"]`：返回 `element` 下方的所有元素。

- `element["Value"]`：返回元素的 `value` 值（如果存在）。

- `element["InnerHTML"]`：返回 `element` 子级对应的 HTML。例如，`<div><b>Great!</b></div>` 的内部 HTML 是 `<b>Great!</b>`。

- `element["InnerHTML", "html"]`：将元素的内部 HTML 设置为 `"html"`。

- `element["OuterHTML"]`：返回 `element` 自身及其所有后代对应的 HTML。例如，`<div><b>Great!</b></div>` 的外部 HTML 是 `<div><b>Great!</b></div>`。

- `element["OwnText"]`：返回直接位于 `element` 下的文本，不包含子元素中的文本。例如，`<p>text <b>more text</b></p>` 中 `p` 的 `"OwnText"` 为 `"text"`，而 `b` 的 `"OwnText"` 为 `"more text"`。

- `element["AllText"]`：返回 `element` 下方的全部文本。例如，对 `html` 元素调用时会返回文档中的全部文本。

- `element["AllText", "text"]`：移除 `element` 下已有的元素和文本，并替换为 `"text"`。

- `element["ID"]`：返回 `ID` 属性。

- `element["ClassNames"]`：返回 `class` 属性中的类名列表。

- `element["HasAttribute", "attr"]`：如果存在属性 `attr`，返回 `True`，否则返回 `False`。

- `element["Attribute", "attr"]`：返回属性 `attr` 的值。

- `element["Attribute", "attr", "value"]`：将属性 `attr` 设置为 `"value"`。

- `element["Attribute", "attr", True | False]`：值为 `True` 时将属性设置为空字符串，值为 `False` 时移除该属性。

- `element["Attribute", assoc]`：按照关联 `assoc` 一次设置多个属性。

- `element["Attributes"]`：以关联形式返回全部属性及其值。

- `element["RemoveAttribute", "attr"]`：移除属性 `attr`。

- `element["IsBlock"]`：如果 `element` 是块级元素，返回 `True`，否则返回 `False`。

- `element["HasText"]`：如果 `element["AllText"]` 不为空字符串，返回 `True`，否则返回 `False`。

- `element["BaseURI"]`：返回文档的基础 URI。

- `element["BaseURI", "uri"]`：设置文档的基础 URI。

- `element["HasClass", "class"]`：如果 `"class"` 出现在元素的 `class` 属性中，返回 `True`，否则返回 `False`。

- `element["AddClass", "class"]`：向元素的 `class` 属性添加类名。

- `element["RemoveClass", "class"]`：从元素的 `class` 属性移除类名。

- `element["ToggleClass", "class"]`：如果元素尚无该类名则添加，否则移除。

- `element["Before", "html"]`：解析 `"html"`，并将所得内容插入 `element` 之前。

- `element["Before", otherElement]`：将 `otherElement` 插入 `element` 之前。

- `element["After", "html"]`：解析 `"html"`，并将所得内容插入 `element` 之后。

- `element["After", otherElement]`：将 `otherElement` 插入 `element` 之后。

- `element["Prepend", "html"]`：解析 `"html"`，并将所得内容插入 `element` 的子元素列表开头。

- `element["Prepend", otherElement]`：将 `otherElement` 插入 `element` 的子元素列表开头。

- `element["Append", "html"]`：解析 `"html"`，并将所得内容追加到 `element` 的子元素列表末尾。

- `element["Append", otherElement]`：将 `otherElement` 追加到 `element` 的子元素列表末尾。

- `element["ReplaceWith", otherElement]`：使用 `otherElement` 替换 `element`。

- `element["Remove"]`：移除 `element`。

- `element["Wrap", "html"]`：解析 `"html"`，并使用所得元素包裹 `element`。

- `element["Unwrap"]`：移除 `element`，但保留其子元素，相当于将子元素上移一级。

- `element["Clean"]`：使用 jsoup 的安全清理机制处理 `element` 及其所有后代，可用于降低 XSS 风险。

- `element["DeepCopy"]`：返回 `element` 的深拷贝；对副本的修改不会影响原元素。

- `element["Properties"]`：列出全部可用属性。

- `element["DOMTree"]`：打开 DOM 树查看界面，详见下文。

## 1.1 便捷函数

上游 1.1 分支新增了 8 个便捷函数。它们只是对属性式调用的包装，因此下面两种写法可以同时使用：

```wl
HTMLChildren[element]
element["Children"]
```

8 个便捷函数与原属性式调用的对应关系如下：

| 1.1 便捷函数 | 等价的属性式调用 | 说明 |
| --- | --- | --- |
| `HTMLSelect[rootElement, selector]` | `rootElement["Select", selector]` | 返回匹配 CSS 选择器的元素；也支持操作符形式 `HTMLSelect[selector][rootElement]`。 |
| `HTMLAttribute[element, attribute]` | `element["Attribute", attribute]` | 返回指定属性的值；也支持操作符形式 `HTMLAttribute[attribute][element]`。 |
| `HTMLAttributes[element]` | `element["Attributes"]` | 以关联形式返回全部属性。 |
| `HTMLParent[element]` | `element["Parent"]` | 返回父元素。 |
| `HTMLChildren[element]` | `element["Children"]` | 返回子元素列表。 |
| `HTMLSiblings[element]` | `element["Siblings"]` | 返回兄弟元素列表。 |
| `HTMLOwnText[element]` | `element["OwnText"]` | 返回元素自身直接包含的文本，不包含子元素中的文本。 |
| `HTMLAllText[element]` | `element["AllText"]` | 返回元素及其后代中的全部文本。 |

例如，可以使用操作符形式选择所有 `p.lead` 元素，再取得第一个元素的文本：

```wl
lead = First@HTMLSelect["p.lead"][document];
HTMLAllText[lead]
```

### `HTMLTree`

上游 1.1 已提供 `HTMLTree` 的文档页面，但没有实现函数定义。本 fork 补全了这一薄包装：

```wl
HTMLTree[element]
```

它与下面的旧属性式调用完全等价：

```wl
element["DOMTree"]
```

## DOM 树界面

`element["DOMTree"]` 或 `HTMLTree[element]` 会打开以 `element` 为根节点的 DOM 树查看界面：

![界面录屏](https://mmase.s3.amazonaws.com/domview.gif)

可以通过单击选择元素。“Copy node”按钮会将对应的 HTML 元素对象写入剪贴板，以便粘贴到 notebook 中；“Copy CSS selector”按钮会复制一个能够唯一标识所选元素的 CSS 选择器。

在 DOM 树窗口中按 `Ctrl+F` 可打开搜索框。输入关键字并点击右侧的 `Search` 按钮后，界面会自动展开并滚动到第一个匹配文本所在的最小元素节点，以浅黄色高亮当前节点；此时“Copy node”和“Copy CSS selector”会直接复制该节点或它的 CSS 选择器。点击 `next` 按钮前往下一个匹配，点击 `prev` 按钮返回上一个匹配，高亮和按钮目标会随之移动。搜索框旁的计数采用“当前序号 / 匹配总数”格式，例如 `2 / 5`。再次按 `Ctrl+F` 可以修改关键字并重新搜索。

## 获取绝对 URL

如果无法从链接中取得绝对 URL，可以尝试读取 `"abs:href"` 属性，而不是 `"href"`：

```wl
element["Attribute", "abs:href"]
```

## 从源码构建

在仓库根目录运行：

```bash
./scripts/build.wls
```

该脚本使用 `PacletBuild` 构建 Paclet，并验证 manifest、解包后的归档、内置 jsoup JAR、文档和入口文件名。构建和隔离安装测试的详细说明参见 [BUILD.md](BUILD.md)。

当前 1.1.1 内置从 Maven Central 获取的 jsoup 1.23.1：

- SHA-1：`0c0350bb325da274f0508349109516a7855d01ab`
- SHA-256：`8b15e2b28eeb1e0a88a9b7dab4dc0c23524491c56959785dea22f7846897b668`

jsoupLink 使用 GPL-2.0-or-later 许可证；内置的 jsoup 依赖使用 MIT 许可证，详情参见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
