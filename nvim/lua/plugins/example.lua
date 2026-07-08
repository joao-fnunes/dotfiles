-- Starter spec: a functional example plugin. gitsigns is the lua-native
-- successor to vim-gitgutter (which plain vim still gets via Vundle). Add more
-- specs as separate files in this directory over time.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {},
}
