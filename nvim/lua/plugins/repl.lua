-- ~/.config/nvim/lua/plugins/repl.lua
return {
  {
    "hkupty/iron.nvim",
    keys = {
      { "<leader>i", mode = { "n" }, desc = "REPL" },
      { "<leader>is", "<cmd>IronRepl<cr>", desc = "Start REPL" },
      { "<leader>ir", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
      { "<leader>if", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
      { "<leader>ih", "<cmd>IronHide<cr>", desc = "Hide REPL" },
    },
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")

      iron.setup({
        config = {
          -- Automatically close REPL window on exit
          close_window_on_exit = true,
          -- Return focus to the original window after executing code
          return_focus = true,
          -- Keymaps available when REPL is active
          repl_definition = {
            python = {
              command = { "ipython" },
              -- Format command for better code handling
              format = require("iron.fts.common").bracketed_paste,
            },
          },
          -- REPL opens in a vertical split
          repl_open_cmd = view.split.vertical.botright(50),
        },
        -- Keymaps for sending code to REPL
        keymaps = {
          send_motion = "<leader>sc",
          visual_send = "<leader>sc",
          send_file = "<leader>sf",
          send_line = "<leader>sl",
          send_until_cursor = "<leader>su",
          send_mark = "<leader>sm",
          mark_motion = "<leader>mc",
          mark_visual = "<leader>mc",
          remove_mark = "<leader>md",
          cr = "<leader>s<cr>",
          interrupt = "<leader>s<space>",
          exit = "<leader>sq",
          clear = "<leader>cl",
        },
        -- Highlight sent code for better visibility
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      })

      -- Custom functions for better REPL interaction
      local function send_and_move()
        local iron = require("iron.core")
        iron.send_line()
        vim.api.nvim_feedkeys("j", "n", false)
      end

      -- Additional keymaps for better workflow
      vim.keymap.set("n", "<leader>sj", send_and_move, { desc = "Send line and move down" })
      vim.keymap.set("v", "<leader>ss", "<cmd>IronVisualSend<cr>", { desc = "Send visual selection" })
    end,
  },
}
