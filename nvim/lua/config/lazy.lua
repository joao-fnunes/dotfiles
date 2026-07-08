-- Bootstrap lazy.nvim. On first launch it self-installs into
-- stdpath("data").."/lazy/lazy.nvim", which resolves per-OS (Linux
-- ~/.local/share/nvim, Windows ~/AppData/Local/nvim-data), so no separate
-- clone step is needed in the install scripts.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leaders must be set before lazy.setup so plugin key mappings register on the
-- intended leader.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Make a C compiler discoverable before any plugin build runs (install steps
-- fire during lazy.setup when `install.missing` pulls new plugins). See
-- config/toolchain.lua -- on Windows this surfaces the bundled LLVM clang so
-- nvim-treesitter can compile parsers.
require("config.toolchain").setup()

-- All plugin specs are auto-imported from lua/plugins/. Missing plugins are
-- installed automatically on startup.
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
  -- None of the starter plugins need luarocks; disabling it keeps
  -- `:checkhealth lazy` clean and avoids a hererocks (lua 5.1 + luarocks)
  -- bootstrap. Flip to `enabled = true` if you add a plugin that needs rockspecs.
  rocks = { enabled = false },
})
