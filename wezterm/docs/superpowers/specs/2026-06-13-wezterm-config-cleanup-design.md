# WezTerm 配置精简（去背景/去圆角/Windows 化）

**日期**：2026-06-13
**范围**：`C:\Users\HowXu\.config\wezterm` 全套配置
**目标**：移除壁纸系统、删除跨平台抽象中的非 Windows 分支、标签页改用 wezterm 默认渲染、shell 精简为 pwsh/nu/cmd 三项、字体统一为 Maple Mono NF CN、右状态栏去掉日历/星期、关闭默认启动全屏、Alt+Enter 改为无边框全屏、GPU 偏好 Vulkan。

---

## 1. 背景

现有配置是为多平台 + 美观壁纸 + 全套快捷键设计的可移植配置。实际使用环境已固化为 Windows + 三个常用 shell，过去的功能（背景图、SSH/WSL 域、macOS/Linux 启动项、默认全屏）成为无用负担。同时标签页的 powerline 半圆字符在用户看来观感差，状态栏的日历/星期也无必要。

本次改动是一次"删繁就简"——保留**配置**的模块结构、保留**配置**的多平台扩展点（`utils/platform.lua` 仍可跨平台），但**默认行为**收敛到 Windows + 三个 shell + Maple Mono + 0.9 背景不透明度。

---

## 2. 行为变更

| 行为 | 当前 | 改后 |
|------|------|------|
| 启动即全屏 | 是 | 否，按系统默认窗口尺寸 |
| Alt+Enter | 新建标签页 | 无边框全屏（ToggleFullScreen） |
| 背景 | 全屏壁纸图 + 0.96 透明叠加 | 无图，纯色 0.9 不透明 |
| 标签页渲染 | 自定义 Nerd Font 半圆 powerline | wezterm 默认（无圆角） |
| 默认 shell | PowerShell | Nushell |
| 启动器 shell 列表 | PowerShell / Git Bash / CMD / Anaconda PowerShell | PowerShell / Nushell / CMD |
| 跨平台启动器 | macOS / Linux 分支 | 仅 Windows |
| F3 启动器中的远程域 | OECT (SSH) / WSL:Ubuntu / WSL:Debian | 无 |
| F6 快捷命令 | Set Proxy (Windows/Linux) / Agent Update | Set Proxy (Windows) / Agent Update |
| 右状态栏 | 日历图标 + 星期 + 时间 + 电池 | 时间 + 电池（无图标、无星期） |
| 字体 | Maple Mono NF CN + 鸿蒙黑体回退 | Maple Mono NF CN（fonts.lua 整体不动，回退仍保留以防字体卸载） |
| GPU 后端优先级（Windows） | Dx12 > Vulkan > Gl | **Vulkan > Dx12 > Gl** |
| 跨平台抽象 (`utils/platform.lua`) | 完整 | **保留**（用户期望） |
| `mod.SUPER` 跨平台分支 | macOS=Cmd，Windows/Linux=Alt | **保留**（用户期望） |

---

## 3. 文件级变更清单

### 3.1 删除（4 项）

| 路径 | 大小 | 理由 |
|------|------|------|
| `utils/backdrops.lua` | 4.4 KB | 壁纸控制整套逻辑 |
| `events/tab-title.lua` | 3.5 KB | 圆角 powerline 渲染，改用 wezterm 默认 |
| `config/domains.lua` | 1.1 KB | SSH/WSL 域，用户不需 |
| `backdrops/` | 目录，~18 MB，14 张图 | 壁纸数据 |

### 3.2 修改（7 项）

#### 3.2.1 `wezterm.lua`

**当前**（28 行）→ **改后**（13 行）：

```lua
local Config = require('config')

require('events.right-status').setup()
require('events.left-status').setup()
require('events.new-tab-button').setup()

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
```

**移除**：
- `require('utils.backdrops'):set_files():random()` 初始化
- `require('events.tab-title').setup()`
- `:append(require('config.domains'))`
- `local wezterm = require 'wezterm'` / `local mux = wezterm.mux`
- 整个 `wezterm.on('gui-attached', ...)` 块（默认全屏逻辑）

#### 3.2.2 `config/appearance.lua`

- 删除 `background = { ... }` 整块（两层的 image + 半透明纯色叠加）
- 新增 `text_background_opacity = 0.9`
- 删除 `local wezterm = require('wezterm')` 引用（不再使用 `wezterm.GLOBAL.background`）
- 其余保留：`animation_fps`、`front_end = 'WebGpu'`、`webgpu_preferred_adapter`、`colors`、`enable_scroll_bar`、`enable_tab_bar`、`use_fancy_tab_bar = false`、`window_decorations`、`window_padding`、`window_close_confirmation`、`window_frame.active_titlebar_bg`、`inactive_pane_hsb`

#### 3.2.3 `config/launch.lua`

**当前**（33 行，3 个 platform 分支）→ **改后**（10 行）：

```lua
local options = {
   default_prog = { 'nu' },
   launch_menu = {
      { label = 'PowerShell', args = { 'pwsh' } },
      { label = 'Nushell',    args = { 'nu' } },
      { label = 'CMD',        args = { 'cmd' } },
   },
}

return options
```

**移除**：
- `local platform = require('utils.platform')()` 引入
- macOS / Linux 分支整段
- Anaconda PowerShell / Git Bash 条目

#### 3.2.4 `config/bindings.lua`

**保留**：
- 顶部 `local platform = require('utils.platform')()` 与 `if platform.is_mac ... elseif ...` 分支（用户要求）
- `mod.SUPER` 键映射逻辑

**修改**：
- 删 `local backdrops = require('utils.backdrops')` 一行
- 删 4 个 backdrop 键位：
  - `key = '/'` + `mod.SUPER` → 随机
  - `key = ','` + `mod.SUPER` → 上一张
  - `key = '.'` + `mod.SUPER` → 下一张
  - `key = '/'` + `mod.SUPER_REV` → 选择器
- F6 `InputSelector.choices`：删除 `{ label = 'Set Proxy (Linux)', id = 'proxy-linux' }` 项，**同时**删除 `elseif id == 'proxy-linux' then` 整个分支
- `key = 'Enter', mods = mod.SUPER`：从 `act.SpawnTab('DefaultDomain')` 改为 `act.ToggleFullScreen`

**保留**：
- `Alt+Ctrl+T` 仍是 `act.SpawnTab('DefaultDomain')`（备用新建标签入口）
- 其余所有键位不变

#### 3.2.5 `events/right-status.lua`

- 将 `_set_date` 函数改名为 `_set_time`
- 改函数体：去掉 `nf.fa_calendar` 图标参数，去掉 ` %a ` 星期格式
- 改后内容：
  ```lua
  local _set_time = function()
     local time = wezterm.strftime(' %H:%M:%S')
     _push(time, '', colors.date_fg, colors.date_bg, true)
  end
  ```
- `setup` 内部调用从 `_set_date()` 改为 `_set_time()`
- `_set_battery` 不变
- 颜色定义保留 `date_fg` / `date_bg`（不重命名以最小化 diff）

#### 3.2.6 `utils/gpu_adapter.lua`

**单行修改**：

```lua
GpuAdapters.AVAILABLE_BACKENDS = {
   windows = { 'Vulkan', 'Dx12', 'Gl' },  -- 原顺序为 Dx12, Vulkan, Gl
   linux = { 'Vulkan', 'Gl' },
   mac = { 'Metal' },
}
```

`__preferred_backend = self.AVAILABLE_BACKENDS[platform.os][1]` 自动取第一个，所以 Windows 默认变 Vulkan。

#### 3.2.7 `KEYBINDINGS.md`

- 顶部"标签页管理"小节：`Alt+Enter` 描述改为 "无边框全屏（同 F11）"，删除"新建标签页"标签
- 删除整个"## 背景壁纸"小节
- "## 快捷命令（F6）"小节：删除 "Set Proxy (Linux)" 条目（包括其 bash 代码块）
- "## SSH 连接"小节：删除（domains.lua 已删，文档不再适用）

### 3.3 保持不变（8 项）

| 路径 | 大小 | 不动理由 |
|------|------|----------|
| `config/init.lua` | 0.8 KB | `Config` 类骨架仍被 `wezterm.lua` 拼装使用 |
| `config/general.lua` | 1.3 KB | hyperlink 规则、scrollback、bell 等通用项与本次目标无关 |
| `config/fonts.lua` | 1.6 KB | 已经使用 `Maple Mono NF CN`；harfbuzz 特性保留（cv/ss/zero） |
| `colors/custom.lua` | 2.3 KB | `tab_bar.*` 配色会被 wezterm 默认 tab 渲染使用 |
| `events/left-status.lua` | 1.8 KB | leader/key-table 状态显示仍有效 |
| `events/new-tab-button.lua` | 0.7 KB | "+" 键点击行为仍适用 |
| `utils/platform.lua` | 0.6 KB | **用户要求保留**（不动 is_mac/is_linux 字段） |
| `utils/math.lua` | 0.3 KB | `clamp`/`round` 仍被 right-status 使用 |

---

## 4. 关键不变量 / 风险点

- **`utils/platform.lua` 与 `config/bindings.lua` 中的跨平台分支保留**——按用户明确要求，逻辑上仍可服务其他平台。本次仅收敛**默认行为**。
- **GPU 后端改 Vulkan 优先**：若用户显卡 Vulkan 驱动不稳，可能回退到 Dx12。`pick_best()` 在 Vulkan 不可用时会返回 nil，让 wezterm 自动选——这一点不变。
- **`text_background_opacity = 0.9` 在 Windows 上**：wezterm 文档支持该字段；效果是终端纯色背景层 90% 不透明、10% 透到桌面。
- **删除 `tab-title.lua` 后**：`colors/custom.lua` 中 `tab_bar.*` 配色直接生效。需在验证时确认配色观感（深色 Mocha 风格应保持）。
- **`backdrops/` 目录删除**：用户已明确要求"有关背景图的部分全删了"。

---

## 5. 验证方案

### 5.1 启动前

```bash
# 语法静态检查
& "C:\Program Files\WezTerm\wezterm.exe" --config-check
```

期望：零错误退出。如果有 Lua 语法错误，立即定位到出错文件。

### 5.2 启动后逐项检查

| # | 期望 | 操作 |
|---|------|------|
| 1 | 默认启动不进入全屏 | 启动 wezterm，看窗口尺寸 |
| 2 | Alt+Enter 进入全屏 | 按下 Alt+Enter |
| 3 | 背景 90% 不透明（透一点点桌面） | 视觉确认 |
| 4 | 标签页无半圆字符，无圆角感 | 视觉确认 |
| 5 | 标签页配色仍是 Mocha 风格（深色） | 视觉确认 |
| 6 | 右状态栏：左→时间，右→电池，无图标，无星期 | 视觉确认 |
| 7 | F3 启动器只有 3 项（PowerShell / Nushell / CMD） | 按 F3 |
| 8 | Alt+Enter 全屏后建新标签默认是 Nushell | 全屏 → Alt+Ctrl+T 建新标签 |
| 9 | F6 菜单只有 2 项 | 按 F6 |
| 10 | 字体是 Maple Mono NF CN | 视觉确认 |
| 11 | Maple Mono NF CN 渲染无 tofu/缺字 | 终端输入 `中文 abc 123`，看字形 |

### 5.3 回归项

确认未改坏的现有功能：

- Ctrl+Shift+C / Ctrl+Shift+V 复制粘贴
- Alt+h / Alt+l 切换标签、Alt+Shift+h / Alt+Shift+l 移动标签
- Alt+\\ 垂直分割、Alt+Ctrl+\\ 水平分割
- Alt+Ctrl+x 关闭窗格（带确认）
- Alt+z 最大化/还原窗格
- Alt+Ctrl+k/j/h/l 窗格导航
- Alt+Ctrl+p 窗格选择器
- Shift+PageUp/PageDown 半页滚动
- Alt+←/→ 行首/行尾
- Alt+F 搜索
- Alt+U URL 快速选择
- Ctrl+鼠标左键 打开链接
- Alt+Ctrl+Space 触发 leader，F 进入字体调整，P 进入窗格调整
- F1 复制模式、F2 命令面板、F4 标签搜索、F5 工作区搜索、F11 全屏、F12 调试

### 5.4 错误检测

```bash
wezterm start --always-new-process
```

看 stderr 有无 Lua 错误。常见错误：
- `attempt to call a nil value` —— 某 `require` 路径已删
- `module 'config.domains' not found` —— wezterm.lua 漏删 `:append`
- `module 'utils.backdrops' not found` —— bindings.lua 漏删 `require`

---

## 6. 范围之外

- 不动 `colors/custom.lua` 中 tab_bar 配色（如有需要后续再调）
- 不动 `config/fonts.lua` 的 harfbuzz 特性（cv/ss/zero）
- 不动 `config/general.lua` 的 hyperlink 规则
- 不动 `events/left-status.lua`、`events/new-tab-button.lua`
- 不新建/不重构 `config/init.lua` 的 `Config` 类
- 不写自动化测试（wezterm 配置无成熟测试框架）

---

## 7. 实施顺序（概要）

1. 删 `backdrops/` 目录、4 个目标文件
2. 改 `wezterm.lua`（最优先，入口文件）
3. 改 `config/appearance.lua`
4. 改 `config/launch.lua`
5. 改 `config/bindings.lua`
6. 改 `events/right-status.lua`
7. 改 `utils/gpu_adapter.lua`
8. 改 `KEYBINDINGS.md`
9. 跑 `wezterm --config-check`
10. 重启 wezterm，按 5.2 逐项验证
11. 跑回归项

详细实施计划由 `writing-plans` 技能另生成。
