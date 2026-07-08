-- indent-blankline (ibl): draws thin vertical guides for each indentation level
-- and highlights the current scope, which makes deeply nested C/C++ and Lua
-- blocks easier to follow. Scope detection uses tree-sitter (treesitter.lua).
-- The `ibl` main module is the v3 API.
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = { char = "│" },
    scope = { enabled = true, show_start = false, show_end = false },
  },
}
