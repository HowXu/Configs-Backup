# VSCodium 自定义样式与脚本

基于 [Custom CSS and JS Loader](https://open-vsx.org/extension/be5invis/vscode-custom-css) 扩展注入，适用于 VSCode / VSCodium。

## 安装

1. 安装 **Custom CSS and JS Loader** 扩展
2. 在 `settings.json` 中配置：

```json
{
  "vscode_custom_css.imports": [
    "file:///xxx.css",
    "file:///xxx.js"
  ],
  "vscode_custom_css.policy": true
}
```

3. 执行 `Ctrl+Shift+P` → `Enable Custom CSS and JS` 并重启

## 文件说明

### CSS

| 文件 | 作用 |
|------|------|
| `css/linenumber.css` | 当前活动行号使用彩虹渐变色填充，并添加发光效果 |
| `css/monacoHover.css` | 编辑器悬浮提示框（hover widget）添加粉→绿流动边框动画 |
| `css/suggestWidget.css` | 编辑器补全建议列表添加冰蓝→炽金流动边框动画 |
| `css/rainbowTab.css` | 选中的标签页顶部边框替换为彩虹渐变色，带色相旋转动画 |
| `css/border.css` | 全局移除所有圆角 |
| `css/logo.css` | 更换开屏Logo |

### JS

| 文件 | 作用 |
|------|------|
| `js/neovide-cursor.js` | 模拟 Neovide 光标的物理拖尾效果 —— 将原生光标替换为 Canvas 渲染的四边形，四个角点各自通过阻尼弹簧独立追踪光标位置，产生拖尾滞后的手感 |

## 效果预览

- **标签页顶部**：激活标签页有流动的彩虹色顶边
- **悬浮提示**：hover 弹出框带循环流动的彩虹边框
- **行号**：当前行号呈彩虹渐变色并发光
- **光标**：移动时四条边有弹簧拖尾动画，静止时延迟淡出
- **圆角**：全局直边直角，无圆角

## 自定义渐变色

`monacoHover.css` 和 `suggestWidget.css` 的边框渐变可以自行修改。找到文件中 `border-box` 的那行：

```css
linear-gradient(to right, #ff758c, #69f0ae, #ff758c) border-box;
                          ^^^^^^^  ^^^^^^^  ^^^^^^^
                          起始色    中间色    结束色
```

**规则**：首尾颜色必须相同，保证循环动画无缝。改中间的颜色即可改变渐变风格。方向可改为 `to bottom`、`to top left` 等。
