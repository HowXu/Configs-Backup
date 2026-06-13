return {
  "dnlhc/glance.nvim",
  config = function()
    require("glance").setup({
     -- detached = true, -- 让它不随光标移动而关闭
    })
  end,
  keys = {
    { "gp", "<cmd>Glance definitions<cr>", desc = "Glance Definition" },
  }
}
