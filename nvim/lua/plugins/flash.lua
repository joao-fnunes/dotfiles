-- flash.nvim: jump anywhere on screen with search labels -- the lua-native
-- successor to vim-easymotion / vim-sneak. Press `s` then a couple of characters
-- of your target; flash labels every match so one more keystroke jumps there
-- (works as a motion in operator-pending and visual modes too). `S` labels the
-- Treesitter nodes around the cursor for structured selection, and `<C-s>` in a
-- `/` search toggles labels on the live matches.
--
-- These maps intentionally take over `s`/`S` (Vim's substitute-char/line, which
-- `c`+motion already covers) as recommended by the plugin. The rhs are lua
-- functions rather than `:lua ...` so jumps stay dot-repeatable.
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
