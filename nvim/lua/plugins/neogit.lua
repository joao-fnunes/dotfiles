-- Neogit: a Magit-style git interface -- stage/unstage hunks, commit, branch,
-- push/pull, rebase and more from a single interactive buffer. This is the
-- heavyweight companion to gitsigns (inline hunks) and diffview (diffs). It can
-- also stand in for vim-fugitive from the plain-vim config. Maps under <leader>g.
return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit status" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
  },
  opts = {
    integrations = { diffview = true, telescope = true },
  },
}
