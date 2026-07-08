-- Lualine: a fast, configurable statusline -- the lua-native replacement for
-- vim-airline. `theme = "auto"` picks up the active colorscheme (tokyonight),
-- and globalstatus draws a single statusline across all splits (laststatus=3).
--
-- nvim-web-devicons provides the filetype/branch glyphs (needs a Nerd Font).
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      section_separators = "",
      component_separators = "|",
    },
  },
}
