return {
  {
    "scottmckendry/cyberdream.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false,
    },
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.cmd.colorscheme("cyberdream")
    end,
  },
}
