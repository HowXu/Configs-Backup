local wezterm = require('wezterm')

local M = {}
local __cells__ = {}

-- Active tab: peach (mocha.peach) bg + dark fg
-- Inactive:  surface0 bg + subtext1 fg
-- Hover:     surface1 bg + text fg
local colors = {
   default = { bg = '#313244', fg = '#a6adc8' },
   is_active = { bg = '#fab387', fg = '#1e1e2e' },
   hover = { bg = '#45475a', fg = '#cdd6f4' },
}

local _push = function(bg, fg, attr, text)
   table.insert(__cells__, { Background = { Color = bg } })
   table.insert(__cells__, { Foreground = { Color = fg } })
   table.insert(__cells__, { Attribute = attr })
   table.insert(__cells__, { Text = text })
end

local _process_name = function(s)
   if not s or s == '' then return '' end
   local a = string.gsub(s, '(.*[/\\])(.*)', '%2')
   return (a:gsub('%.exe$', ''))
end

M.setup = function()
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      __cells__ = {}

      local bg, fg
      if tab.is_active then
         bg, fg = colors.is_active.bg, colors.is_active.fg
      elseif hover then
         bg, fg = colors.hover.bg, colors.hover.fg
      else
         bg, fg = colors.default.bg, colors.default.fg
      end

      local process_name = _process_name(tab.active_pane.foreground_process_name)
      local pane_title = tab.active_pane.title or ''

      local content
      if #pane_title > 0 then
         content = pane_title
      elseif #process_name > 0 then
         content = process_name
      else
         content = 'shell'
      end

      _push(bg, fg, { Intensity = 'Bold' }, '  ')
      _push(bg, fg, { Intensity = 'Bold' }, content)
      _push(bg, fg, { Intensity = 'Bold' }, '  ')

      return __cells__
   end)
end

return M
