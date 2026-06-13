# WezTerm 配置精简实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 wezterm 配置从"多平台 + 壁纸 + 默认全屏"的复杂形态精简为"Windows + 三 shell + 0.9 背景 + 默认 tab 渲染"形态，删 4 个文件、改 7 个文件、改 1 个文档。

**Architecture:** 保留现有 `config/*` + `events/*` + `utils/*` 的模块结构，每个文件就地更新；新增/删除通过 `wezterm.lua` 拼装链的修改体现。跨平台抽象 (`utils/platform.lua`) 保留不动；行为收敛在 `config/launch.lua`、`config/bindings.lua` 中的 Windows 分支。

**Tech Stack:** Lua（wezterm 配置）、wezterm 配置 schema、PowerShell（执行 wezterm CLI）、Bash（git 命令）。

**参考文档：**
- Spec：`docs/superpowers/specs/2026-06-13-wezterm-config-cleanup-design.md`
- wezterm 文档：https://wezfurlong.org/wezterm/

---

## 文件级映射（任务分解前的总览）

| 路径 | 动作 | 任务 |
|------|------|------|
| `backdrops/` | 删目录 | T1 |
| `utils/backdrops.lua` | 删文件 | T1 |
| `events/tab-title.lua` | 删文件 | T1 |
| `config/domains.lua` | 删文件 | T1 |
| `wezterm.lua` | 改 | T2 |
| `config/appearance.lua` | 改 | T3 |
| `config/launch.lua` | 改 | T4 |
| `config/bindings.lua` | 改 | T5 |
| `events/right-status.lua` | 改 | T6 |
| `utils/gpu_adapter.lua` | 改 | T7 |
| `KEYBINDINGS.md` | 改 | T8 |
| （验证） | 改 | T9 |

---

### Task 1: 删除 4 个目标文件 / 目录

**Files:**
- Delete: `C:\Users\HowXu\.config\wezterm\backdrops\`
- Delete: `C:\Users\HowXu\.config\wezterm\utils\backdrops.lua`
- Delete: `C:\Users\HowXu\.config\wezterm\events\tab-title.lua`
- Delete: `C:\Users\HowXu\.config\wezterm\config\domains.lua`

- [ ] **Step 1.1: 删除 backdrops 目录（含 14 张图）**

```bash
Remove-Item -LiteralPath "C:\Users\HowXu\.config\wezterm\backdrops" -Recurse -Force
```

- [ ] **Step 1.2: 删除 utils/backdrops.lua**

```bash
Remove-Item -LiteralPath "C:\Users\HowXu\.config\wezterm\utils\backdrops.lua" -Force
```

- [ ] **Step 1.3: 删除 events/tab-title.lua**

```bash
Remove-Item -LiteralPath "C:\Users\HowXu\.config\wezterm\events\tab-title.lua" -Force
```

- [ ] **Step 1.4: 删除 config/domains.lua**

```bash
Remove-Item -LiteralPath "C:\Users\HowXu\.config\wezterm\config\domains.lua" -Force
```

- [ ] **Step 1.5: 验证四个文件 / 目录都已不存在**

```bash
Test-Path "C:\Users\HowXu\.config\wezterm\backdrops"; `
Test-Path "C:\Users\HowXu\.config\wezterm\utils\backdrops.lua"; `
Test-Path "C:\Users\HowXu\.config\wezterm\events\tab-title.lua"; `
Test-Path "C:\Users\HowXu\.config\wezterm\config\domains.lua"
```

Expected：四个结果都是 `False`。如果任一为 `True`，重复对应 step。

- [ ] **Step 1.6: 提交删除（独立 commit 便于回滚）**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/backdrops wezterm/utils/backdrops.lua wezterm/events/tab-title.lua wezterm/config/domains.lua
git -C "C:\Users\HowXu\.config" commit -m "wezterm: drop backdrop/tab-title/domains modules"
```

> 注：若 `git -C "C:\Users\HowXu\.config" status` 显示 wezterm/ 整体仍未 tracked，需先 `git add wezterm/`。具体见 task 末尾的 git 状态说明。

---

### Task 2: 改 `wezterm.lua` 入口文件

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\wezterm.lua`（全文件替换）

- [ ] **Step 2.1: 把 wezterm.lua 替换为以下 13 行内容**

完整新内容（替换整个文件）：

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

- [ ] **Step 2.2: 验证内容**

```bash
Get-Content "C:\Users\HowXu\.config\wezterm\wezterm.lua"
```

Expected：13 行，与上面代码块一致。

- [ ] **Step 2.3: 暂存但不提交**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/wezterm.lua
```

（暂不 commit，等所有任务完成一起 commit，见 T9）

---

### Task 3: 改 `config/appearance.lua`

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\config\appearance.lua`

- [ ] **Step 3.1: 删 `local wezterm = require('wezterm')`**

wezterm 模块不再需要（`wezterm.GLOBAL.background` 在删除 background 块后不再引用）。

把第 1 行 `local wezterm = require('wezterm')` 整行删除。

- [ ] **Step 3.2: 在 `colors = colors,` 之后插入 `text_background_opacity = 0.9`**

找到这一段：

```lua
   -- color scheme
   colors = colors,

   -- background
   background = {
      ...
   },
```

替换为：

```lua
   -- color scheme
   colors = colors,

   -- 0.9 不透明背景 (10% 透)
   text_background_opacity = 0.9,
```

**注意**：原 `background = { ... }` 整个块（10 行左右，从 `-- background` 注释到末尾的 `},`）一并删除。

- [ ] **Step 3.3: 验证最终内容**

```bash
Get-Content "C:\Users\HowXu\.config\wezterm\config\appearance.lua"
```

Expected 关键行：
- 文件首行是 `local gpu_adapters = require('utils.gpu_adapter')`
- 含 `text_background_opacity = 0.9,`
- **不含** `background = {`
- **不含** `source = { File = ...`
- **不含** `local wezterm = require('wezterm')`
- 文件以 `inactive_pane_hsb = {` 和 `},` 结尾

- [ ] **Step 3.4: 暂存**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/config/appearance.lua
```

---

### Task 4: 改 `config/launch.lua`

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\config\launch.lua`（全文件替换）

- [ ] **Step 4.1: 替换整个文件为以下 10 行内容**

完整新内容：

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

- [ ] **Step 4.2: 验证**

```bash
Get-Content "C:\Users\HowXu\.config\wezterm\config\launch.lua"
```

Expected：10 行，无 `local platform`、`is_win`、`is_mac`、`is_linux`、`Anaconda`、`Git Bash`、`fish`、`zsh`、`bash` 任意关键词。

- [ ] **Step 4.3: 暂存**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/config/launch.lua
```

---

### Task 5: 改 `config/bindings.lua`

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\config\bindings.lua`

- [ ] **Step 5.1: 删除 `local backdrops = require('utils.backdrops')` 一行**

在文件中找到该行（位于第 3 行，紧跟在 `local platform = require('utils.platform')()` 之后），整行删除。删除后 `local act = wezterm.action` 上移一行（空行保留）。

- [ ] **Step 5.2: 删除 4 个 backdrop 键位**

在文件中找到整个 `-- background controls --` 段（含 4 个键位，Alt+/, Alt+,, Alt+., Alt+Ctrl+/），整段删除。

从第 100 行附近的 `-- background controls --` 注释开始，到第 136 行 `end),` 后面的 `},` 结束（4 个键位大约 36 行）。

- [ ] **Step 5.3: 在 F6 `InputSelector.choices` 表中删除 "Set Proxy (Linux)" 项**

找到第 39 行附近：
```lua
              { label = 'Set Proxy (Linux)', id = 'proxy-linux' },
```

整行删除。

- [ ] **Step 5.4: 删除 F6 中的 proxy-linux 处理分支**

找到第 46 行附近：
```lua
              elseif id == 'proxy-linux' then
                 pane:send_text('export HTTP_PROXY=http://127.0.0.1:2080; export HTTPS_PROXY=http://127.0.0.1:2080\r')
```

整段（约 2 行）删除。

- [ ] **Step 5.5: 改 Alt+Enter 键位**

找到第 86 行附近：
```lua
   { key = 'Enter',      mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
```

替换为：
```lua
   { key = 'Enter',      mods = mod.SUPER,     action = act.ToggleFullScreen },
```

- [ ] **Step 5.6: 验证文件**

```bash
Get-Content "C:\Users\HowXu\.config\wezterm\config\bindings.lua"
```

Expected 关键检查：
- **不含** `backdrops`（任何大小写）
- **不含** `proxy-linux`
- **不含** `export HTTP_PROXY`
- 第 86 行附近的 `key = 'Enter'` 对应 `act.ToggleFullScreen`
- **保留** `local platform = require('utils.platform')()`
- **保留** `if platform.is_mac then ... elseif ... end` 整段
- **保留** `key = 't'` + `mod.SUPER_REV` → `act.SpawnTab('DefaultDomain')`（Alt+Ctrl+T 仍能建新标签）

- [ ] **Step 5.7: 暂存**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/config/bindings.lua
```

---

### Task 6: 改 `events/right-status.lua`

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\events\right-status.lua`

- [ ] **Step 6.1: 把 `_set_date` 改名为 `_set_time`**

找到第 63 行附近：
```lua
local _set_date = function()
```

替换为：
```lua
local _set_time = function()
```

- [ ] **Step 6.2: 改函数体：去图标、去星期**

找到函数体（约 3 行）：
```lua
   local date = wezterm.strftime(' %a %H:%M:%S')
   _push(date, nf.fa_calendar, colors.date_fg, colors.date_bg, true)
end
```

替换为：
```lua
   local time = wezterm.strftime(' %H:%M:%S')
   _push(time, '', colors.date_fg, colors.date_bg, true)
end
```

- [ ] **Step 6.3: 更新 setup 内的调用**

找到第 91 行附近 `M.setup` 函数内：
```lua
      _set_date()
      _set_battery()
```

替换为：
```lua
      _set_time()
      _set_battery()
```

- [ ] **Step 6.4: 验证**

```bash
Get-Content "C:\Users\HowXu\.config\wezterm\events\right-status.lua"
```

Expected 关键检查：
- **不含** `_set_date`
- **不含** `nf.fa_calendar`
- **不含** ` %a `
- **含** `local _set_time = function()`
- **含** `wezterm.strftime(' %H:%M:%S')`
- **保留** `_set_battery` 整段不变
- **保留** `colors.date_fg` / `colors.date_bg`（不重命名以最小化 diff）
- **保留** `M.setup` 内部对 `update-right-status` 事件的注册

- [ ] **Step 6.5: 暂存**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/events/right-status.lua
```

---

### Task 7: 改 `utils/gpu_adapter.lua`（单行修改）

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\utils\gpu_adapter.lua:30-34`

- [ ] **Step 7.1: 改 Windows 后端顺序**

找到第 30-34 行：
```lua
GpuAdapters.AVAILABLE_BACKENDS = {
   windows = { 'Dx12', 'Vulkan', 'Gl' },
   linux = { 'Vulkan', 'Gl' },
   mac = { 'Metal' },
}
```

替换为：
```lua
GpuAdapters.AVAILABLE_BACKENDS = {
   windows = { 'Vulkan', 'Dx12', 'Gl' },
   linux = { 'Vulkan', 'Gl' },
   mac = { 'Metal' },
}
```

- [ ] **Step 7.2: 验证**

```bash
Select-String -Path "C:\Users\HowXu\.config\wezterm\utils\gpu_adapter.lua" -Pattern "windows = "
```

Expected：返回 `windows = { 'Vulkan', 'Dx12', 'Gl' },` 一行。

- [ ] **Step 7.3: 暂存**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/utils/gpu_adapter.lua
```

---

### Task 8: 改 `KEYBINDINGS.md`

**Files:**
- Modify: `C:\Users\HowXu\.config\wezterm\KEYBINDINGS.md`

- [ ] **Step 8.1: 改 Alt+Enter 描述**

找到"## 标签页管理"小节（约第 27-37 行）的第一行：
```markdown
| `Alt+Enter` | 新建标签页 |
```

替换为：
```markdown
| `Alt+Enter` | 无边框全屏（ToggleFullScreen） |
```

- [ ] **Step 8.2: 删除整个"## 背景壁纸"小节**

找到第 68-75 行附近（"## 背景壁纸" 标题到下一个 `##` 标题之间的所有内容）：

```markdown
## 背景壁纸

| 快捷键 | 功能 |
|--------|------|
| `Alt+/` | 随机切换壁纸 |
| `Alt+,` | 上一张壁纸 |
| `Alt+.` | 下一张壁纸 |
| `Alt+Ctrl+/` | 打开壁纸选择菜单 |
```

整段删除（包括小节标题和之后的空行）。

- [ ] **Step 8.3: 改 F6 快捷命令小节：删除 Linux 代理**

找到第 129-143 行附近（"## 快捷命令（F6）" 下的第 2 条）：

```markdown
2. **Set Proxy (Linux)** - 设置临时代理（Linux/macOS）
   ```bash
   export HTTP_PROXY=http://127.0.0.1:2080
   export HTTPS_PROXY=http://127.0.0.1:2080
   ```
```

整段删除。

- [ ] **Step 8.4: 删除"## SSH 连接"小节**

找到第 153-160 行的整个"## SSH 连接"小节：

```markdown
## SSH 连接

SSH 连接已移至域配置（`config/domains.lua`）。

使用方式：
1. 按 `F3` 打开启动器
2. 选择配置的 SSH 服务器
3. 像本地标签页一样使用远程终端
```

整段删除。

- [ ] **Step 8.5: 验证文档**

```bash
Select-String -Path "C:\Users\HowXu\.config\wezterm\KEYBINDINGS.md" -Pattern "背景壁纸|Set Proxy .Linux|domains\.lua|新建标签页"
```

Expected：无输出（四个关键词都不再出现）。

- [ ] **Step 8.6: 暂存**

```bash
git -C "C:\Users\HowXu\.config" add wezterm/KEYBINDINGS.md
```

---

### Task 9: 完整验证

- [ ] **Step 9.1: 静态检查 wezterm 配置**

```bash
& "C:\Program Files\WezTerm\wezterm.exe" --config-check
```

Expected：进程退出码 0，stdout/stderr 无错误。常见错误：
- `module 'config.domains' not found` —— T2 漏删 `:append(require('config.domains'))`
- `module 'utils.backdrops' not found` —— T5 漏删 `local backdrops = require(...)`
- `attempt to index a nil value (field 'background')` —— T3 漏删 background 块
- `attempt to call a nil value (global 'backdrops')` —— T5 漏改某 backdrop 键位

- [ ] **Step 9.2: 重启 wezterm 验证视觉项**

按 spec 5.2 节 11 项逐项人工检查：

| # | 期望 | 实际（用户填） |
|---|------|--------------|
| 1 | 默认启动不进入全屏 | ☐ |
| 2 | Alt+Enter 进入全屏 | ☐ |
| 3 | 背景 90% 不透明（透一点点桌面） | ☐ |
| 4 | 标签页无半圆字符、无圆角感 | ☐ |
| 5 | 标签页配色仍是 Mocha 风格（深色） | ☐ |
| 6 | 右状态栏：左→时间，右→电池，无图标，无星期 | ☐ |
| 7 | F3 启动器只有 3 项（PowerShell / Nushell / CMD） | ☐ |
| 8 | 新建标签默认是 Nushell | ☐ |
| 9 | F6 菜单只有 2 项 | ☐ |
| 10 | 字体是 Maple Mono NF CN | ☐ |
| 11 | 终端无 tofu/缺字（输入 `中文 abc 123`） | ☐ |

- [ ] **Step 9.3: 回归项检查**

按 spec 5.3 节列表逐项验证（复制粘贴、tab 导航、分割、字号调整、leader、搜索、链接等）。任一项失败，回到对应 task 修复。

- [ ] **Step 9.4: 提交所有暂存**

```bash
git -C "C:\Users\HowXu\.config" status -s
```

Expected：显示 7 个 modified 文件（wezterm.lua + 5 个 config/* 或 events/* + 1 个 utils/*）和 KEYBINDINGS.md（1 个 modified），加 T1 已提交的 4 个 deleted。

```bash
git -C "C:\Users\HowXu\.config" commit -m "wezterm: simplify config (Windows-only, no backdrops, default tab render)

- Add text_background_opacity = 0.9
- Remove backdrop system (backdrops/ dir, utils/backdrops.lua, 4 keybindings)
- Remove tab-title powerline rendering (use wezterm default)
- Remove SSH/WSL domains (config/domains.lua)
- launch_menu: pwsh/nu/cmd only; default_prog = nu
- Alt+Enter: ToggleFullScreen
- Right status: time + battery (no calendar/weekday)
- F6 menu: drop 'Set Proxy (Linux)'
- GPU: prefer Vulkan on Windows
- Remove default fullscreen on startup
- Update KEYBINDINGS.md"
```

- [ ] **Step 9.5: 确认 commit 成功**

```bash
git -C "C:\Users\HowXu\.config" log --oneline -5
```

Expected：最顶上一条是新 commit，hash 8 位起头。

---

## 自审（写完计划后）

1. **Spec 覆盖检查**：spec 第 2 节列出的 13 项行为变更，每一项都能在本计划中找到对应 step：
   - 默认启动不进入全屏 → T2 + T9.2
   - Alt+Enter 改 ToggleFullScreen → T5.5 + T9.2
   - 背景 0.9 不透明、无图 → T3.2 + T9.2
   - 标签页默认渲染 → T1（删 tab-title.lua）+ T9.2
   - 默认 shell = nu、launch_menu 3 项 → T4
   - 跨平台分支删 → T4
   - F3 远程域删 → T1
   - F6 去掉 Linux 代理 → T5.3 + T5.4
   - 右状态栏无日历/星期 → T6
   - 字体 Maple Mono NF CN（保持）→ 无修改，T9.2 验证
   - GPU Vulkan 优先 → T7
   - 跨平台抽象保留 → 无修改
   - mod.SUPER 跨平台分支保留 → T5.6 验证

2. **占位符扫描**：无 "TBD"、"TODO"、"适当"、"类似" 等模糊词。

3. **类型 / 名称一致性**：
   - `_set_date` → `_set_time` 改了三处一致（T6.1 定义、T6.2 函数体、T6.3 setup 调用）
   - `pwsh` / `nu` / `cmd` 在 T4.1 launch_menu 与 T9.2 验证项 7 描述中一致
   - 文件路径全程用绝对路径 `C:\Users\HowXu\.config\wezterm\...`，一致

4. **测试覆盖**：配置无单元测试，T9.1 `wezterm --config-check` 作为静态检查 smoke test，T9.2 11 项 + T9.3 回归项作为手动验证。已对每条 spec 要求都映射到验证项。

## 实施后回顾

完成后回看 spec 第 5 节是否全部通过；任一项失败 → 对应 task → 修复 → 重新跑 T9。
