-- Neo-tree: a modern file explorer sidebar -- the lua-native replacement for
-- NERDTree. The <C-b><C-t> / <C-b><C-f> maps mirror the old NERDTreeToggle /
-- NERDTreeFind bindings from the plain-vim config so muscle memory carries over.
--
-- nvim-web-devicons supplies the file glyphs (needs a Nerd Font); nui.nvim and
-- plenary.nvim are pure-Lua libraries with no build step.
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-b><C-t>", "<cmd>Neotree toggle<cr>", desc = "File explorer (toggle)" },
    { "<C-b><C-f>", "<cmd>Neotree reveal<cr>", desc = "File explorer (reveal current file)" },
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File explorer" },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      -- Track and reveal the file of the current buffer, and react to on-disk
      -- changes without a manual refresh.
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      filtered_items = { hide_dotfiles = false, hide_gitignored = false },
    },
  },
}
