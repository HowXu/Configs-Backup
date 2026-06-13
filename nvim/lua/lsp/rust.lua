return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        rust_analyzer = {
          mason = false,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = false,
              cargo = {
                allTargets = false,
                noDefaultFeatures = true,
                features = {},
              },
              procMacro = { enable = false },
              diagnostics = {
                disabled = { "unresolved-proc-macro" },
              },
              cachePriming = { enable = false },
              files = { watcher = "notify" },
              lens = { enable = false },
              inlayHints = {
                typeHints = { enable = false },
                parameterHints = { enable = false },
              },
            },
          },
        },
      },
    },
  },
}
