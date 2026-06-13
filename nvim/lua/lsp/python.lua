return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        -- 1. Pyright: 负责代码分析、跳转、类型检查
        pyright = {
          mason = false,
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                typeCheckingMode = "basic", -- 可选 "strict" 如果你追求严苛的类型检查
                diagnosticMode = "workspace",
              },
            },
          },
        },
        -- 2. Ruff: 负责格式化 (替代 Black) 和 静态检查 (替代 Flake8)
        ruff = {
          -- 这里的配置可以让 Ruff 在保存时自动组织 import 顺序
          mason = false,
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports.ruff" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Organize Imports",
            },
          },
        },
      },
      -- 3. 针对所有 Python LSP 关闭自动补全的参数占位符
      setup = {
        pyright = function(_, opts)
          -- 确保 Pyright 补全时不带参数
          opts.settings.python.analysis.completeFunctionParens = false
        end,
      },
    },
  },
}
