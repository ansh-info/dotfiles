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
  -- Enhanced Harpoon configuration
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      -- Basic operations
      {
        "<leader>ha",
        function()
          require("harpoon.mark").add_file()
          vim.notify("File added to Harpoon", vim.log.levels.INFO)
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
      -- File navigation with Meta/Alt + number
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
      -- New navigation commands
      {
        "<leader>hn",
        function()
          require("harpoon.ui").nav_next()
        end,
        desc = "Next Harpoon Mark",
      },
      {
        "<leader>hp",
        function()
          require("harpoon.ui").nav_prev()
        end,
        desc = "Prev Harpoon Mark",
      },
      -- Remove current file from Harpoon
      {
        "<leader>hr",
        function()
          require("harpoon.mark").rm_file()
          vim.notify("File removed from Harpoon", vim.log.levels.INFO)
        end,
        desc = "Remove from Harpoon",
      },
      -- Clear all Harpoon marks
      {
        "<leader>hc",
        function()
          require("harpoon.mark").clear_all()
          vim.notify("Cleared all Harpoon marks", vim.log.levels.INFO)
        end,
        desc = "Clear All Harpoon Marks",
      },
      -- List marks in Telescope
      {
        "<leader>ht",
        function()
          require("telescope").load_extension("harpoon")
          require("telescope").extensions.harpoon.marks()
        end,
        desc = "List Harpoon Marks in Telescope",
      },
    },
    opts = {
      global_settings = {
        save_on_toggle = true,
        save_on_change = true,
        enter_on_sendcmd = false,
        tmux_autoclose_windows = false,
        excluded_filetypes = { "harpoon" },
        mark_branch = false,
      },
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
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
