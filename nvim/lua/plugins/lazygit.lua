-- Add to ~/.config/nvim/lua/plugins/lazygit.lua

return {
  "kdheepak/lazygit.nvim",
  -- optional dependencies
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- setup keymaps
    vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { silent = true, desc = "Open LazyGit" })

    -- Optional: Configure lazygit window
    vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
    vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" } -- customize border chars
    vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
    vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

    -- Optional: Set up custom lazygit config path
    -- vim.g.lazygit_config_file_path = '~/.config/lazygit/config.yml'
  end,
}
