-- persistence.nvim: remembers your editing session (open buffers, window/split
-- layout, tab pages, cwd, folds) keyed by project directory and restores it on
-- demand -- the lua-native successor to `:mksession`. Sessions save automatically
-- when you quit, so each project reopens exactly how you left it; you pull one
-- back with the <leader>q maps below.
--
-- Restore is deliberately manual (not on every launch) so opening a file
-- directly still gives a clean editor. (Marks, registers, search/command history
-- and the recent-files list persist separately via Neovim's built-in shada.)
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore session (cwd)" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save current session" },
  },
}
