-- ~/.config/nvim/lua/plugins/venv.lua

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>v", mode = { "n" }, desc = "venv" }, -- Parent menu with venv icon
      { "<leader>ve", "<cmd>VenvManager<cr>", desc = " Venv Manager" },
      { "<leader>vE", "<cmd>VenvCreate<cr>", desc = " Create Venv" },
    },
    config = function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local Job = require("plenary.job")

      -- Cache for Python versions
      local python_versions_cache = nil

      -- Function to get installed Python versions with async detection
      local function get_python_versions(callback)
        if python_versions_cache then
          callback(python_versions_cache)
          return
        end

        local versions = {}
        local pending = 0
        local completed = false

        local function check_complete()
          pending = pending - 1
          if completed and pending == 0 then
            -- Sort versions
            table.sort(versions, function(a, b)
              return a.version > b.version
            end)
            python_versions_cache = versions
            callback(versions)
          end
        end

        -- Function to add version asynchronously
        local function add_version(path)
          pending = pending + 1
          Job:new({
            command = path,
            args = { "--version" },
            on_exit = function(j, code)
              if code == 0 then
                local result = j:result()[1]
                local version = result:match("Python%s+([%d%.]+)")
                if version then
                  table.insert(versions, { version = version, path = path })
                end
              end
              check_complete()
            end,
          }):start()
        end

        -- Check Homebrew Python installations
        local brew_paths = {
          "/opt/homebrew/bin/python3",
          "/opt/homebrew/bin/python3.11",
          "/opt/homebrew/bin/python3.10",
          "/opt/homebrew/bin/python3.9",
          "/opt/homebrew/bin/python3.8",
        }

        -- Check system Python
        local system_paths = {
          "/usr/bin/python3",
          "/usr/local/bin/python3",
        }

        -- Add all potential paths
        for _, path in ipairs(brew_paths) do
          if vim.fn.executable(path) == 1 then
            add_version(path)
          end
        end

        for _, path in ipairs(system_paths) do
          if vim.fn.executable(path) == 1 then
            add_version(path)
          end
        end

        -- Check pyenv if available
        if vim.fn.executable("pyenv") == 1 then
          pending = pending + 1
          Job:new({
            command = "pyenv",
            args = { "versions", "--bare" },
            on_exit = function(j, code)
              if code == 0 then
                for _, version in ipairs(j:result()) do
                  local path = os.getenv("HOME") .. "/.pyenv/versions/" .. version .. "/bin/python3"
                  if vim.fn.executable(path) == 1 then
                    add_version(path)
                  end
                end
              end
              check_complete()
            end,
          }):start()
        end

        completed = true
        if pending == 0 then
          callback(versions)
        end
      end

      -- Function to validate environment directory
      local function validate_env_dir()
        local env_path = vim.fn.getcwd() .. "/env"
        return vim.fn.isdirectory(env_path) ~= 1
      end

      -- Function to list virtual environments
      local function list_venv_environments()
        local environments = {}
        local cwd = vim.fn.getcwd()

        local venv_locations = {
          cwd .. "/env",
          cwd .. "/venv",
          cwd .. "/.venv",
        }

        for _, location in ipairs(venv_locations) do
          if vim.fn.isdirectory(location) == 1 then
            local activate_path = location .. "/bin/activate"
            if vim.fn.filereadable(activate_path) == 1 then
              -- Get Python version
              local version = "unknown"
              local python_path = location .. "/bin/python3"
              local handle = io.popen(python_path .. " --version 2>&1")
              if handle then
                local result = handle:read("*a")
                handle:close()
                version = result:match("Python%s+([%d%.]+)") or "unknown"
              end

              table.insert(environments, {
                name = vim.fn.fnamemodify(location, ":t"),
                path = location,
                python_version = version,
              })
            end
          end
        end

        return environments
      end

      -- Function to safely restart LSP with proper buffer handling
      local function restart_lsp()
        -- Save current buffer number and cursor position
        local current_buf = vim.api.nvim_get_current_buf()
        local current_win = vim.api.nvim_get_current_win()
        local cursor_pos = vim.api.nvim_win_get_cursor(current_win)
        local bufname = vim.api.nvim_buf_get_name(current_buf)

        -- Stop all LSP clients
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
          vim.lsp.stop_client(client.id)
        end

        vim.defer_fn(function()
          -- Only reload if it's a real file
          if bufname and bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
            -- Keep the same buffer and reload it
            vim.cmd("checktime")
            -- Restore cursor position
            vim.api.nvim_win_set_cursor(current_win, cursor_pos)
          end
          vim.notify("LSP restarted", vim.log.levels.INFO)
        end, 500)
      end

      -- Function to activate virtual environment
      local function activate_venv(venv_info)
        local env_path = venv_info.path

        vim.env.VIRTUAL_ENV = env_path
        vim.env.PATH = env_path .. "/bin:" .. vim.env.PATH
        vim.env.PYTHONHOME = nil
        vim.g.python3_host_prog = env_path .. "/bin/python"

        local activation_cmd = "source " .. env_path .. "/bin/activate"
        vim.notify(
          string.format(
            "Activated environment: %s\nPython version: %s\nTo activate in terminal: %s",
            venv_info.name,
            venv_info.python_version,
            activation_cmd
          ),
          vim.log.levels.INFO
        )

        restart_lsp()
      end

      -- Function to create virtual environment with selected Python version
      local function create_venv_with_version(python_info)
        if not validate_env_dir() then
          vim.notify("Environment 'env' already exists in current directory", vim.log.levels.ERROR)
          return
        end

        -- Store cwd before async operation
        local cwd = vim.fn.getcwd()

        Job:new({
          command = python_info.path,
          args = { "-m", "venv", "env" },
          cwd = cwd,
          on_exit = function(j, code)
            if code == 0 then
              local activation_cmd = "source " .. cwd .. "/env/bin/activate"
              vim.notify(
                string.format(
                  "Successfully created virtual environment!\n"
                    .. "Python Version: %s\n"
                    .. "Location: %s/env\n"
                    .. "To activate in terminal: %s",
                  python_info.version,
                  cwd,
                  activation_cmd
                ),
                vim.log.levels.INFO
              )
            else
              vim.notify("Failed to create virtual environment. Exit code: " .. code, vim.log.levels.ERROR)
            end
          end,
        }):start()
      end

      -- Function to show Python version selection
      local function show_python_version_selector()
        vim.notify("Detecting Python versions...", vim.log.levels.INFO)
        get_python_versions(function(versions)
          if #versions == 0 then
            vim.notify("No Python installations found", vim.log.levels.ERROR)
            return
          end

          vim.schedule(function()
            pickers
              .new({}, {
                prompt_title = " Select Python Version",
                finder = finders.new_table({
                  results = versions,
                  entry_maker = function(entry)
                    return {
                      value = entry,
                      display = " Python " .. entry.version .. " (" .. entry.path .. ")",
                      ordinal = entry.version,
                    }
                  end,
                }),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    create_venv_with_version(selection.value)
                  end)
                  return true
                end,
              })
              :find()
          end)
        end)
      end

      -- Environment selection function
      local function venv_manager()
        local envs = list_venv_environments()

        if #envs == 0 then
          vim.notify(
            "No virtual environments found in current directory.\n" .. "Create one with :VenvCreate or <leader>vE",
            vim.log.levels.WARN
          )
          return
        end

        pickers
          .new({}, {
            prompt_title = " Python Virtual Environments",
            finder = finders.new_table({
              results = envs,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = string.format(" %s (Python %s)", entry.name, entry.python_version),
                  ordinal = entry.name,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                activate_venv(selection.value)
              end)
              return true
            end,
          })
          :find()
      end

      -- Register commands
      vim.api.nvim_create_user_command("VenvManager", venv_manager, {})
      vim.api.nvim_create_user_command("VenvCreate", show_python_version_selector, {})
    end,
  },
}
