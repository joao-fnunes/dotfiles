-- Bufdelete: closes a buffer while leaving its window (and your split layout)
-- intact -- the lua-native replacement for vim-bufkill's :BD. <C-b><C-x>
-- mirrors the old :BD binding from the shared vimrc.
return {
  "famiu/bufdelete.nvim",
  cmd = { "Bdelete", "Bwipeout" },
  keys = {
    { "<C-b><C-x>", "<cmd>Bdelete<cr>", desc = "Delete buffer (keep window)" },
    { "<leader>bd", "<cmd>Bdelete<cr>", desc = "Delete buffer" },
  },
}
