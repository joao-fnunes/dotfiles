-- Bufferline: renders open buffers as clickable tabs along the top, with LSP
-- diagnostic counts. Complements the <Tab>/<S-Tab> buffer cycling already set
-- in the shared vimrc. The neo-tree offset keeps the tab strip from sitting on
-- top of the file-explorer sidebar.
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      offsets = {
        { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", separator = true },
      },
    },
  },
}
