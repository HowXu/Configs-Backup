-- 关闭动态行
vim.opt.relativenumber = false
vim.opt.number = true
-- theme
-- vim.cmd.colorscheme("kanagawa")
-- 静默LSP消息
vim.lsp.handlers["$/progress"] = function() end
-- 缩进长度
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
-- 关闭自动折叠
vim.opt.textwidth = 0
vim.opt.formatoptions:remove("a")
vim.opt.foldmethod = "manual"
vim.opt.foldenable = false
-- 关闭自动格式化
vim.g.autoformat = false
-- 自动保存
local save_timer
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    if save_timer then
      pcall(vim.uv.close, save_timer)
    end
    save_timer = vim.defer_fn(function()
      if vim.fn.expand("%") ~= "" and vim.bo.modified then
        vim.cmd("silent write")
      end
    end, 2000)
  end,
})

-- 全部block光标
vim.opt.guicursor = "n-v-c-sm-i-ci-ve-r-cr-o:block"

-- windows only / no cmd
-- nushell
if vim.fn.has("win32") then
  vim.o.shell = "nu.exe"
end

if vim.g.neovide then
  -- neovide config

  vim.o.guifont = "Maple Mono NF CN" -- text below applies for VimScript
  vim.g.neovide_scale_factor = 0.85

  vim.g.neovide_opacity = 0.85
  vim.g.neovide_normal_opacity = 0.85

  vim.g.neovide_theme = "light"

  vim.g.neovide_refresh_rate_idle = 5

  vim.g.neovide_refresh_rate = 60
  -- so fucking my keyboard do not have F11
  vim.keymap.set("n", "<M-CR>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end)
end