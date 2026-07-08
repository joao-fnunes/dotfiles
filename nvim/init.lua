-- Neovim entry point.
--
-- Shared editor settings live in `vimrc` (linked to ~/.vimrc and used by plain
-- vim too). The Vundle plugin block in vimrc is gated behind `!has('nvim')`, so
-- sourcing it here applies settings only -- Neovim's plugins are managed by
-- lazy.nvim (see lua/config/lazy.lua).
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(vimrc))
end

require("config.lazy")
