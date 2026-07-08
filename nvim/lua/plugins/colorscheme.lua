-- Starter spec: colorscheme. Loaded eagerly (high priority) so it applies at
-- startup rather than after other plugins.
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("tokyonight-night")
  end,
}
