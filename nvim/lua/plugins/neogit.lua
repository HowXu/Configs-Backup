return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    -- Only one of these is needed.
    "sindrets/diffview.nvim",        -- optional
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
  }
}
