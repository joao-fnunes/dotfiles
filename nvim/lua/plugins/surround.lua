-- nvim-surround: add/change/delete surrounding pairs (quotes, brackets, tags) --
-- the lua-native replacement for vim-surround. Same muscle memory: ys<motion>
-- to add, cs to change, ds to delete a surround (e.g. cs"' swaps "..." for '...').
-- Pinned to tagged releases for stability.
return {
  "kylechui/nvim-surround",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  opts = {},
}
