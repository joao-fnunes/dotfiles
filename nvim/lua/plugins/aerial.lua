-- Aerial: a code outline window of the symbols in the current file (functions,
-- classes, methods, ...) -- the lua-native replacement for Tagbar, mapped to
-- the same <C-b><C-g> toggle. It prefers LSP symbols (e.g. clangd for C/C++)
-- and falls back to tree-sitter, so no ctags database is required.
return {
  "stevearc/aerial.nvim",
  cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-b><C-g>", "<cmd>AerialToggle!<cr>", desc = "Symbol outline (toggle)" },
    { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Symbol outline" },
  },
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = { default_direction = "right" },
  },
}
