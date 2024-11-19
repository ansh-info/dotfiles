-- ~/.config/nvim/lua/plugins/web-dev.lua

return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- TypeScript/JavaScript
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
              },
            },
          },
        },

        -- CSS
        cssls = {
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },

        -- HTML
        html = {
          filetypes = { "html", "javascriptreact", "typescriptreact" },
        },

        -- Emmet for HTML/CSS snippets
        emmet_ls = {
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
          },
        },
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "typescript",
          "javascript",
          "tsx",
          "html",
          "css",
          "json",
          "scss",
        })
      end
    end,
  },

  -- Formatting configuration
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
      },
    },
  },
}
