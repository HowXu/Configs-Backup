local colors = require('colors.custom')

return {
   animation_fps = 60,
   max_fps = 60,
   front_end = 'OpenGL',

   -- color scheme
   colors = colors,

   -- 真窗口半透明 (76% 不透明 / 24% 透到桌面)
   window_background_opacity = 0.76,
   text_background_opacity = 1.0,

   -- scrollbar
   enable_scroll_bar = false,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = false,
   use_fancy_tab_bar = false,
   tab_max_width = 30,
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- initial window size (slightly larger than wezterm default 80x24)
   initial_cols = 100,
   initial_rows = 30,

   -- window
   window_decorations = "INTEGRATED_BUTTONS | RESIZE",
   window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
   },
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = 'rgba(0, 0, 0, 0)',
      inactive_titlebar_bg = 'rgba(0, 0, 0, 0)',
      active_titlebar_fg = '#dbe7f3',
      inactive_titlebar_fg = '#9fb0c4',
      font_size = 13,   -- slightly larger X / - / [] buttons
   },
   inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.65,
   },
}
