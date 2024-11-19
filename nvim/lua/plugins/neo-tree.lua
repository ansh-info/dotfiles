return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- When true, they will just be displayed differently than normal items
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
