-- file: ~/.config/nvim/lua/plugins/no-lsp-auto-install.lua
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {},
      automatic_installation = false,
    },
  },
}