-- ~/.config/nvim/lua/plugins/navigation.lua
return {
  -- Improved f/t motions
  {
    "ggandor/flit.nvim",
    keys = function()
      local ret = {}
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },

  -- Jump to any location
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
    },
  },
  --
  -- -- Better buffer navigation
  -- {
  --   "ThePrimeagen/harpoon",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   keys = {
  --     {
  --       "<leader>ha",
  --       function()
  --         require("harpoon.mark").add_file()
  --       end,
  --       desc = "Add to Harpoon",
  --     },
  --     {
  --       "<leader>hh",
  --       function()
  --         require("harpoon.ui").toggle_quick_menu()
  --       end,
  --       desc = "Harpoon Menu",
  --     },
  --     {
  --       "<C-h>",
  --       function()
  --         require("harpoon.ui").nav_file(1)
  --       end,
  --       desc = "Harpoon File 1",
  --     },
  --     {
  --       "<C-j>",
  --       function()
  --         require("harpoon.ui").nav_file(2)
  --       end,
  --       desc = "Harpoon File 2",
  --     },
  --     {
  --       "<C-k>",
  --       function()
  --         require("harpoon.ui").nav_file(3)
  --       end,
  --       desc = "Harpoon File 3",
  --     },
  --     {
  --       "<C-l>",
  --       function()
  --         require("harpoon.ui").nav_file(4)
  --       end,
  --       desc = "Harpoon File 4",
  --     },
  --   },
  --   opts = {
  --     global_settings = {
  --       save_on_toggle = true,
  --       save_on_change = true,
  --     },
  --   },
  -- },

  -- Better buffer navigation
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>ha",
        function()
          require("harpoon.mark").add_file()
        end,
        desc = "Add to Harpoon",
      },
      {
        "<leader>hh",
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
        desc = "Harpoon Menu",
      },
      -- Changed from C-h/j/k/l to M-1/2/3/4 (Alt/Meta + number)
      {
        "<M-1>",
        function()
          require("harpoon.ui").nav_file(1)
        end,
        desc = "Harpoon File 1",
      },
      {
        "<M-2>",
        function()
          require("harpoon.ui").nav_file(2)
        end,
        desc = "Harpoon File 2",
      },
      {
        "<M-3>",
        function()
          require("harpoon.ui").nav_file(3)
        end,
        desc = "Harpoon File 3",
      },
      {
        "<M-4>",
        function()
          require("harpoon.ui").nav_file(4)
        end,
        desc = "Harpoon File 4",
      },
    },
    opts = {
      global_settings = {
        save_on_toggle = true,
        save_on_change = true,
      },
    },
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = false,
      detection_methods = { "pattern", "lsp" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pom.xml" },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = "global",
    },
    event = "VeryLazy",
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
    },
  },
}
