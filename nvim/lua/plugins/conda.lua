-- Create: ~/.config/nvim/lua/plugins/conda.lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>c9", "<cmd>CondaManager<cr>", desc = "Conda Environment Manager" },
      { "<leader>c8", "<cmd>CondaCreate<cr>", desc = "Create Conda Environment" },
    },
    config = function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

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

      -- Function to list conda environments
      local function list_conda_envs()
        -- First check if conda is available
        local conda_check = get_command_output("command -v conda")
        if not conda_check or conda_check == "" then
          vim.notify("Conda is not available in PATH", vim.log.levels.ERROR)
          return {}
        end

        -- Get conda environments
        local result = get_command_output("conda env list --json")
        if not result then
          vim.notify("Failed to get conda environments", vim.log.levels.ERROR)
          return {}
        end

        -- Safely decode JSON
        local ok, decoded = pcall(vim.fn.json_decode, result)
        if not ok or not decoded or not decoded.envs then
          vim.notify("Failed to parse conda environments", vim.log.levels.ERROR)
          return {}
        end

        -- Extract environment names
        local env_names = {}
        for _, env in ipairs(decoded.envs) do
          local name = vim.fn.fnamemodify(env, ":t")
          if name and name ~= "" then
            table.insert(env_names, name)
          end
        end

        return env_names
      end

      -- Create environment function
      local function create_conda_env()
        -- Create an input prompt for environment name
        vim.ui.input({ prompt = "Enter new environment name: " }, function(env_name)
          if not env_name or env_name == "" then
            vim.notify("No environment name provided", vim.log.levels.WARN)
            return
          end

          -- Create floating window for packages
          vim.ui.input({ prompt = "Enter packages (space-separated): " }, function(packages)
            if not packages then
              packages = ""
            end

            -- Create terminal window
            vim.cmd("split")
            local cmd = string.format("conda create -n %s python %s", env_name, packages)
            vim.notify("Creating environment: " .. env_name, vim.log.levels.INFO)
            vim.cmd("terminal " .. cmd)
          end)
        end)
      end

      -- List and select environment function
      local function conda_manager()
        pickers
          .new({}, {
            prompt_title = "Conda Environments",
            finder = finders.new_table({
              results = list_conda_envs(),
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry,
                  ordinal = entry,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()

                -- Activate the selected environment
                local env_path =
                  get_command_output(string.format("conda env list | grep '%s' | awk '{print $2}'", selection.value))

                if not env_path then
                  vim.notify("Failed to get environment path", vim.log.levels.ERROR)
                  return
                end

                env_path = vim.fn.trim(env_path)

                -- Set environment variables
                vim.env.CONDA_PREFIX = env_path
                vim.env.VIRTUAL_ENV = env_path
                vim.env.PATH = env_path .. "/bin:" .. vim.env.PATH
                vim.g.python3_host_prog = env_path .. "/bin/python"

                -- Notify user
                vim.notify("Activated environment: " .. selection.value, vim.log.levels.INFO)

                -- Reload LSP
                vim.cmd("LspRestart")
              end)
              return true
            end,
          })
          :find()
      end

      -- Register commands
      vim.api.nvim_create_user_command("CondaManager", conda_manager, {})
      vim.api.nvim_create_user_command("CondaCreate", create_conda_env, {})
    end,
  },
}
