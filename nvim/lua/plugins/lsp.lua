-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Lua configuration
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        -- Python configuration
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
      },
    },
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- LSP
        "lua-language-server",
        "pyright",
        --[[         "typescript-language-server", ]]
        "css-lsp",
        "html-lsp",
        -- Formatters
        "prettier",
        -- Linters
        "eslint-lsp",
        "marksman",
      })
      return opts
    end,
  },

  -- Mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "lua_ls",
        "pyright",
        "cssls",
        "html",
        "marksman",
      })
      return opts
    end,
  },

  -- Extend auto-completion
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
      })
      return opts
    end,
  },

  -- -- Import LazyVim's TypeScript configuration
  -- { import = "lazyvim.plugins.extras.lang.typescript" },
}
