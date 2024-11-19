-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      -- Get conda env
      local function conda_env()
        local conda_prefix = vim.env.CONDA_PREFIX
        if conda_prefix then
          -- Extract env name from path
          local env_name = vim.fn.fnamemodify(conda_prefix, ":t")
          return "󱔎 " .. env_name -- Using a Python icon
        end
        return ""
      end

      -- Insert conda env component into the statusline
      table.insert(opts.sections.lualine_x, conda_env)

      return opts
    end,
  },
}
