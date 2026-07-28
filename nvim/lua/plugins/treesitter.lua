-- Tree-sitter: fast, incremental parsing that powers accurate syntax
-- highlighting and indentation (far better than regex syntax for C/C++, Lua,
-- Python, etc.). Many plugins in this config build on it (aerial's treesitter
-- backend, indent-blankline scope, render-markdown).
--
-- Parsers are compiled from C on install. That needs a C compiler on PATH --
-- config/toolchain.lua surfaces the bundled LLVM clang on Windows, so no manual
-- setup is required. `tar` + `curl` (both ship with modern Windows) fetch the
-- grammar sources. `:TSUpdate` (the build step) recompiles parsers on updates.
--
-- Pinned to the `main` branch: it is the only branch that supports Neovim 0.12+.
-- The older `master` branch is frozen at Neovim 0.11 and *crashes* on 0.12 --
-- its markdown injection query runs a custom `set-lang-from-info-string!`
-- directive whose handler passes a node LIST to get_node_text under 0.12's new
-- handler API ("attempt to call method 'range' (a nil value)"). `main` drops
-- that directive (markdown injections resolve natively), fixing the crash.
--
-- `main` is a full rewrite with a different API: there is no
-- `configs.setup{ ensure_installed, highlight, indent }`. Instead we install the
-- parser set explicitly, and highlighting/indent are enabled per buffer via
-- vim.treesitter (Neovim provides them; the plugin only ships parsers+queries).
--
-- Requirements for `main`: besides the C compiler above, it shells out to the
-- `tree-sitter` CLI (>= 0.26.1) to run `tree-sitter build` for *every* parser,
-- so the CLI must be on PATH -- bootstrap.ps1 installs it via winget
-- (tree-sitter.tree-sitter-cli). Install it with your package manager, NOT npm
-- (the npm build is unsupported upstream). `main` does NOT support lazy-loading,
-- hence `lazy = false` (no event/cmd triggers).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- `main` installs parsers/queries into `install_dir` (default
    -- stdpath("data").."/site"). Neovim normally has that "site" dir on its
    -- runtimepath, but lazy.nvim rebuilds rtp and drops it -- so the installed
    -- parsers/queries would be invisible and highlighting would silently do
    -- nothing. Passing install_dir to setup() prepends it back onto rtp (and is
    -- where install() writes), which restores discovery under lazy.
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- A practical set for this machine's stack (C/C++, Lua, Python, shell,
    -- config formats, git). Note: there is no PowerShell tree-sitter parser
    -- upstream, so .ps1 keeps Vim's regex syntax. install() is asynchronous and
    -- a no-op for parsers already present, so it is safe to call on every
    -- startup -- it is the `main`-branch replacement for `ensure_installed`.
    require("nvim-treesitter").install({
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
    })

    -- On `main`, highlighting is not a module you toggle -- Neovim provides it
    -- and you start it per buffer. Do that for every filetype whose parser is
    -- installed. The pcall guards the two benign failures: filetypes with no
    -- parser, and buffers opened before the async install above has finished on
    -- first launch (reopening the buffer then picks up highlighting). Setting
    -- the (experimental) tree-sitter indentexpr mirrors master's `indent.enable`.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function(ev)
        if pcall(vim.treesitter.start, ev.buf) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
