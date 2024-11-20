-- ~/.config/nvim/lua/plugins/markdown.lua

return {
  -- Markdown LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline" })
      end
    end,
  },

  -- -- -- Markdown preview (fixed installation)
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
  --   ft = { "markdown" },
  --   build = function()
  --     vim.fn["system"]("cd app && npm install")
  --   end,
  --   init = function()
  --     vim.g.mkdp_filetypes = { "markdown" }
  --   end,
  --   keys = {
  --     { "<leader>cp", ft = "markdown", "<cmd>MarkdownPreview<cr>", desc = "Preview Markdown" },
  --   },
  -- },
  --
  -- Better markdown navigation and editing
  {
    "preservim/vim-markdown",
    dependencies = "godlygeek/tabular",
    ft = { "markdown" },
    init = function()
      -- Enable TOC window auto-fit
      vim.g.vim_markdown_toc_autofit = 1
      -- Enable conceal for formatting
      vim.g.vim_markdown_conceal = 2
      -- Enable math rendering
      vim.g.vim_markdown_math = 1
      -- Enable YAML front matter
      vim.g.vim_markdown_frontmatter = 1
      -- Disable default mappings
      vim.g.vim_markdown_no_default_key_mappings = 1
    end,
  },

  -- Formatting configuration
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "prettier" },
      },
    },
  },
}
