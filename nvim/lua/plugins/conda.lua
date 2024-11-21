-- ~/.config/nvim/lua/plugins/conda.lua

local M = {}

-- Initialize the module with required dependencies
local function init_module()
  M.pickers = require("telescope.pickers")
  M.finders = require("telescope.finders")
  M.conf = require("telescope.config").values
  M.actions = require("telescope.actions")
  M.action_state = require("telescope.actions.state")
  M.Job = require("plenary.job")
end

-- Function to safely read command output
local function get_command_output(command)
  local handle = io.popen(command)
  if handle == nil then
    vim.notify("Failed to execute command: " .. command, vim.log.levels.ERROR)
    return nil
  end

  local result = handle:read("*a")
  local success, _, code = handle:close()

  if not success then
    vim.notify("Command failed with exit code: " .. (code or "unknown"), vim.log.levels.ERROR)
    return nil
  end

  return result
end

-- Function to validate environment name
local function validate_env_name(name)
  if not name or name == "" or not string.match(name, "^[%w_]+$") then
    return false
  end

  local envs = get_command_output("conda env list")
  if envs and string.find(envs, name) then
    return false
  end

  return true
end

-- Function to get available Python versions
local function get_python_versions()
  local versions = {
    "3.12",
    "3.11",
    "3.10",
    "3.9",
    "3.8",
    "3.7",
  }
  return versions
end

-- Function to create conda environment
local function create_conda_env(name, python_version)
  if not validate_env_name(name) then
    vim.notify("Invalid environment name or environment already exists", vim.log.levels.ERROR)
    return
  end

  M.Job
    :new({
      command = "conda",
      args = { "create", "-n", name, "python=" .. python_version, "-y" },
      on_exit = function(j, code)
        if code == 0 then
          vim.notify(
            string.format("Successfully created conda environment '%s' with Python %s", name, python_version),
            vim.log.levels.INFO
          )
        else
          vim.notify(
            string.format("Failed to create conda environment '%s'. Exit code: %d", name, code),
            vim.log.levels.ERROR
          )
        end
      end,
    })
    :start()
end

-- Function to prompt for Python version
local function select_python_version(env_name)
  M.pickers
    .new({}, {
      prompt_title = "Select Python Version",
      finder = M.finders.new_table({
        results = get_python_versions(),
      }),
      sorter = M.conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        M.actions.select_default:replace(function()
          M.actions.close(prompt_bufnr)
          local selection = M.action_state.get_selected_entry()
          create_conda_env(env_name, selection[1])
        end)
        return true
      end,
    })
    :find()
end

-- Function to prompt for environment name
local function prompt_env_creation()
  init_module() -- Ensure dependencies are loaded
  vim.ui.input({ prompt = "Enter new environment name: " }, function(name)
    if name then
      if validate_env_name(name) then
        select_python_version(name)
      else
        vim.notify("Invalid environment name or environment already exists", vim.log.levels.ERROR)
      end
    end
  end)
end

-- Function to list conda environments
local function list_conda_envs()
  local conda_check = get_command_output("command -v conda")
  if not conda_check or conda_check == "" then
    vim.notify("Conda is not available in PATH", vim.log.levels.ERROR)
    return {}
  end

  local result = get_command_output("conda env list --json")
  if not result then
    vim.notify("Failed to get conda environments", vim.log.levels.ERROR)
    return {}
  end

  local ok, decoded = pcall(vim.fn.json_decode, result)
  if not ok or not decoded or not decoded.envs then
    vim.notify("Failed to parse conda environments", vim.log.levels.ERROR)
    return {}
  end

  local env_names = {}
  for _, env in ipairs(decoded.envs) do
    local name = vim.fn.fnamemodify(env, ":t")
    if name and name ~= "" then
      table.insert(env_names, name)
    end
  end

  return env_names
end

-- Function to safely restart LSP
local function restart_lsp()
  local function reload_current_buf()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
      vim.cmd("e!")
    end
  end

  local active_clients = vim.lsp.get_clients()
  for _, client in ipairs(active_clients) do
    vim.lsp.stop_client(client.id)
  end

  vim.defer_fn(function()
    reload_current_buf()
    vim.notify("LSP restarted", vim.log.levels.INFO)
  end, 500)
end

-- Environment selection function
local function conda_manager()
  init_module() -- Ensure dependencies are loaded
  M.pickers
    .new({}, {
      prompt_title = "Conda Environments",
      finder = M.finders.new_table({
        results = list_conda_envs(),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry,
            ordinal = entry,
          }
        end,
      }),
      sorter = M.conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        M.actions.select_default:replace(function()
          M.actions.close(prompt_bufnr)
          local selection = M.action_state.get_selected_entry()

          local env_path =
            get_command_output(string.format("conda env list | grep '%s' | awk '{print $2}'", selection.value))

          if not env_path then
            vim.notify("Failed to get environment path", vim.log.levels.ERROR)
            return
          end

          env_path = vim.fn.trim(env_path)

          vim.env.CONDA_PREFIX = env_path
          vim.env.VIRTUAL_ENV = env_path
          vim.env.PATH = env_path .. "/bin:" .. vim.env.PATH
          vim.g.python3_host_prog = env_path .. "/bin/python"

          vim.notify("Activated environment: " .. selection.value, vim.log.levels.INFO)

          restart_lsp()
        end)
        return true
      end,
    })
    :find()
end

-- Plugin specification
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>v", mode = { "n" }, desc = "venv" },
    {
      "<leader>vc",
      function()
        conda_manager()
      end,
      desc = "Conda Environment Manager",
    },
    {
      "<leader>vC",
      function()
        prompt_env_creation()
      end,
      desc = "Create Conda Environment",
    },
  },
}
