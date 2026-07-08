-- Mason: a package manager for external editor tooling -- LSP servers (clangd,
-- lua-language-server, pyright, ...), DAP debug adapters (codelldb) and
-- formatters/linters. It downloads prebuilt binaries into
-- stdpath("data")/mason and prepends its bin dir to PATH, so language servers
-- work without installing them system-wide.
--
-- This spec only bootstraps Mason itself. Which servers get installed is driven
-- by mason-lspconfig (see lspconfig.lua) and dap.lua. `:Mason` opens the UI to
-- browse/install/update tooling; `:MasonUpdate` refreshes the registry.
--
-- Canonical repo is the `mason-org` organization (the old `williamboman/*`
-- paths now redirect there).
return {
  "mason-org/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
  build = ":MasonUpdate",
  opts = {},
}
