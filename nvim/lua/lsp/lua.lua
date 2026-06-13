return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Disable",
              },
            },
          },
        },
      },
    },
  },
}
