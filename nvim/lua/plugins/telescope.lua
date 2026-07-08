-- Telescope: fuzzy finder for files, live grep, buffers, help, LSP symbols and
-- more -- the lua-native replacement for the plain-vim fzf.vim / ctrlp.vim
-- setup. <C-p> and <C-b><C-b> mirror the old FZF / CtrlPBuffer bindings.
--
-- External tools: live_grep needs ripgrep (rg) and find_files prefers fd; both
-- are installed by the Windows bootstrap (see bootstrap.ps1). telescope-fzf-
-- native is intentionally NOT used here -- its CMake build needs a full
-- toolchain (Ninja/VS generator, not just clang), which this setup doesn't
-- provide. Telescope's built-in sorter is plenty for a personal config.
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<C-b><C-b>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
  },
  opts = {
    defaults = {
      -- Drop matches straight into the results as you type; keep the prompt at
      -- the top.
      sorting_strategy = "ascending",
      layout_config = { prompt_position = "top" },
    },
    pickers = {
      find_files = { hidden = true },
    },
  },
}
