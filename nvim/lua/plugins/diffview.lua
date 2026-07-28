-- Diffview: a full-window git diff, merge-conflict and file-history UI. Pairs
-- with gitsigns (which handles inline hunk signs/staging) by giving you the
-- big-picture side-by-side view and per-file history. neogit (neogit.lua) uses
-- it for its diffs too. Maps live under the <leader>g "git" group.
--
-- Uses diffview+ (dlyongemallo/diffview-plus.nvim), the actively maintained
-- fork of sindrets/diffview.nvim (upstream dormant since Jun 2024). It's a
-- drop-in replacement: same `diffview` Lua module, same commands, so keymaps
-- and neogit's diffview integration keep working unchanged.
return {
  "dlyongemallo/diffview-plus.nvim",
  version = "*",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view (working tree)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
  },
  opts = {},
}
