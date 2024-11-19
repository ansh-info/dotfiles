-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Add to ~/.config/nvim/lua/config/keymaps.lua
-- Base run function
local function run_file()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")

  local commands = {
    python = string.format("python3 %s", filename),
    javascript = string.format("node %s", filename),
    typescript = string.format("ts-node %s", filename),
    lua = string.format("lua %s", filename),
    rust = "cargo run",
    cpp = string.format("g++ %s -o temp && ./temp", filename),
    c = string.format("gcc %s -o temp && ./temp", filename),
    go = "go run .",
    java = string.format("javac %s && java %s", filename, vim.fn.expand("%:r")),
  }

  local cmd = commands[filetype]
  if cmd then
    vim.cmd("split")
    vim.cmd("terminal " .. cmd)
  else
    print("No run command defined for filetype: " .. filetype)
  end
end

-- Run with input file
local function run_file_with_input()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local input_file = vim.fn.expand("%:r") .. ".input"

  local commands = {
    python = string.format("python3 %s < %s", filename, input_file),
    cpp = string.format("g++ %s -o temp && ./temp < %s", filename, input_file),
    c = string.format("gcc %s -o temp && ./temp < %s", filename, input_file),
  }

  local cmd = commands[filetype]
  if cmd then
    vim.cmd("split")
    vim.cmd("terminal " .. cmd)
  else
    print("No input run command defined for filetype: " .. filetype)
  end
end

-- Format and run
local function format_and_run()
  vim.lsp.buf.format()
  vim.cmd("write")
  run_file()
end

-- Run with time
local function run_file_with_time()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")

  local commands = {
    python = string.format("time python3 %s", filename),
    javascript = string.format("time node %s", filename),
    cpp = string.format("time g++ %s -o temp && time ./temp", filename),
    c = string.format("time gcc %s -o temp && time ./temp", filename),
  }

  local cmd = commands[filetype]
  if cmd then
    vim.cmd("split")
    vim.cmd("terminal " .. cmd)
  else
    print("No time command defined for filetype: " .. filetype)
  end
end

-- Run in floating window
local function run_in_float()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")

  local commands = {
    python = string.format("python3 %s", filename),
    javascript = string.format("node %s", filename),
    cpp = string.format("g++ %s -o temp && ./temp", filename),
    c = string.format("gcc %s -o temp && ./temp", filename),
  }

  local cmd = commands[filetype]
  if cmd then
    -- Create floating window
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local buf = vim.api.nvim_create_buf(false, true)
    -- Store window handle but don't assign to variable since we don't need it
    vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width) / 2),
      row = math.floor((vim.o.lines - height) / 2),
      style = "minimal",
      border = "rounded",
    })

    -- Run command in floating window
    vim.fn.termopen(cmd)
  else
    print("No float command defined for filetype: " .. filetype)
  end
end

-- Debug run
local function debug_run()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")

  local commands = {
    python = string.format("python3 -m pdb %s", filename),
    javascript = string.format("node --inspect-brk %s", filename),
    cpp = string.format("gdb ./temp", filename),
    rust = "rust-lldb target/debug/$(basename $(pwd))",
  }

  local cmd = commands[filetype]
  if cmd then
    vim.cmd("split")
    vim.cmd("terminal " .. cmd)
  else
    print("No debug command defined for filetype: " .. filetype)
  end
end

-- Error handling wrapper
local function safe_run(func)
  return function()
    local ok, err = pcall(func)
    if not ok then
      vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

-- Keybindings with error handling
vim.keymap.set("n", "<leader>r", safe_run(run_file), { desc = "Run current file" })
vim.keymap.set("n", "<leader>ri", safe_run(run_file_with_input), { desc = "Run with input file" })
vim.keymap.set("n", "<leader>rf", safe_run(format_and_run), { desc = "Format and run" })
vim.keymap.set("n", "<leader>rt", safe_run(run_file_with_time), { desc = "Run with time" })
vim.keymap.set("n", "<leader>rF", safe_run(run_in_float), { desc = "Run in floating window" })
vim.keymap.set("n", "<leader>rd", safe_run(debug_run), { desc = "Debug run" })

-- -- Optional: Add which-key registration
-- pcall(function()
--   require("which-key").register({
--     ["<leader>r"] = { name = "Run", _ = "which_key_ignore" },
--   })
-- end)
