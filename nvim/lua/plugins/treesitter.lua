-- Tree-sitter: fast, incremental parsing that powers accurate syntax
-- highlighting and indentation (far better than regex syntax for C/C++, Lua,
-- Python, etc.). Many plugins in this config build on it (aerial's treesitter
-- backend, indent-blankline scope, render-markdown).
--
-- Parsers are compiled from C on install. That needs a C compiler on PATH --
-- config/toolchain.lua surfaces the bundled LLVM clang on Windows, so no manual
-- setup is required. `:TSUpdate` (the build step) recompiles them on updates.
--
-- Pinned to the `master` branch on purpose: it exposes the stable classic
-- `require("nvim-treesitter.configs").setup(...)` API. The rewritten `main`
-- branch has a different, still-maturing API.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "TSInstall", "TSUpdate", "TSUpdateSync" },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- A practical set for this machine's stack (C/C++, Lua, Python, shell,
      -- config formats, git). Note: there is no PowerShell tree-sitter parser
      -- upstream, so .ps1 keeps Vim's regex syntax.
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "query",
        "bash",
        "python",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
        "gitcommit",
        "git_rebase",
        "diff",
      },
      -- Only build the parsers listed above; don't silently compile a parser
      -- the first time an unlisted filetype is opened.
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
