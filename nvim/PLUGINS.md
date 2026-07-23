# Neovim plugins

This document explains every plugin ("extension") installed in this Neovim
configuration, how it is loaded, and the key mappings it adds. Plugins are
managed by [lazy.nvim](https://github.com/folke/lazy.nvim); the pinned versions
live in [`lazy-lock.json`](./lazy-lock.json).

## How the configuration is organized

```
nvim/
├── init.lua                 # sources ~/.vimrc (shared settings), then loads lazy
├── lua/
│   ├── config/
│   │   ├── lazy.lua         # bootstraps lazy.nvim, sets leaders, loads plugin specs
│   │   └── toolchain.lua    # makes the bundled LLVM clang discoverable (Windows)
│   └── plugins/*.lua        # one file per plugin spec, auto-imported by lazy
└── lazy-lock.json           # pinned plugin commits (committed to git)
```

- **One file per plugin.** Every file under `lua/plugins/` returns a lazy.nvim
  spec and starts with a comment explaining *why* the plugin is here and any
  gotchas. Add a plugin by dropping a new file in that directory.
- **Lazy loading.** Most plugins load on demand — on an event (`event`), a
  command (`cmd`), a key (`keys`), or a filetype (`ft`) — so startup stays fast.
  The trigger for each plugin is listed below.
- **Leaders.** `<leader>` is **Space** and `<localleader>` is **`\`** (set in
  `config/lazy.lua`).
- **Shared settings.** General editor options (search, indent, `<Tab>`/`<S-Tab>`
  buffer cycling, `<C-b>…` chords, clipboard, etc.) come from the repo's
  [`vimrc`](../vimrc), which `init.lua` sources. Plain vim still manages *its*
  plugins with Vundle; Neovim uses lazy.nvim instead.

### The clang toolchain shim (`config/toolchain.lua`)

Some plugins compile native code: `nvim-treesitter` builds its parsers from C.
On Windows the bootstrap installs LLVM under `C:\Program Files\LLVM`, but that
package does **not** put `clang` on `PATH`, so parser builds would fail with "no
C compiler found". `config/toolchain.lua` runs before `lazy.setup()` and, only
when no compiler is already discoverable, prepends the LLVM `bin` directory to
Neovim's `PATH` for the session. It is fully guarded, so it is a no-op on
Linux/macOS and on Windows machines that already expose a compiler.

## Key mapping conventions

`<leader>` groups (shown in the which-key popup):

| Prefix | Group | Used by |
| --- | --- | --- |
| `<leader>f` | find | telescope |
| `<leader>g` | git | diffview, neogit |
| `<leader>c` | code | LSP (code action, diagnostics, clangd switch) |
| `<leader>b` | buffer | bufferline, bufdelete |
| `<leader>x` | diagnostics | trouble |
| `<leader>d` | debug | nvim-dap / nvim-dap-ui |
| `<leader>q` | session | persistence |

Several `<C-b>…` chords and other keys are carried over from the plain-vim
config so muscle memory still works (see the reference table at the end).

---

## Plugin manager

| Plugin | Purpose |
| --- | --- |
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager. Self-installs on first launch, auto-installs missing plugins, runs build steps, and pins versions in `lazy-lock.json`. |

## Core: language intelligence & finding

| Plugin | What it does | Replaces | Loads on |
| --- | --- | --- | --- |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Incremental parsing for accurate syntax highlighting and indentation. Parsers compile via the clang shim. | vim regex syntax | `BufReadPre`, `BufNewFile` |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Package manager for external tooling (LSP servers, DAP adapters, formatters). `:Mason` opens the UI. | — | `:Mason…` commands |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configs — definition, references, hover, rename, code actions, diagnostics. Uses the Neovim 0.11 `vim.lsp` API. | deoplete-clang, vim-rtags | `BufReadPre`, `BufNewFile` |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Fast autocompletion (LSP, path, snippets, buffer) with signature help. Uses a prebuilt Rust matcher. | deoplete | `InsertEnter`, `CmdlineEnter` |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder for files, live grep, buffers, help, LSP symbols. Needs `ripgrep`/`fd`. | fzf.vim, ctrlp.vim | `:Telescope`, keys |

**LSP servers** (`mason-lspconfig` auto-installs these on first launch):
`clangd`, `lua_ls`, `pyright`, `rust_analyzer`, `powershell_es`.

**Tree-sitter parsers** pre-listed for install: `c`, `cpp`, `lua`, `luadoc`,
`vim`, `vimdoc`, `query`, `bash`, `python`, `json`, `yaml`, `toml`, `markdown`,
`markdown_inline`, `gitcommit`, `git_rebase`, `diff`. (There is no PowerShell
tree-sitter parser upstream, so `.ps1` keeps vim's regex syntax.)

> `telescope-fzf-native` is intentionally **not** used: its CMake build needs a
> full generator (Ninja/Visual Studio), not just clang. Telescope's built-in
> sorter is used instead.

## Navigation & UI

| Plugin | What it does | Replaces | Loads on |
| --- | --- | --- | --- |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer sidebar; follows the current file and watches the filesystem. | NERDTree | `:Neotree`, keys |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline themed to match the colorscheme; single global statusline. | vim-airline | `VeryLazy` |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Open buffers as tabs with LSP diagnostic counts. | airline tabline | `VeryLazy` |
| [aerial.nvim](https://github.com/stevearc/aerial.nvim) | Symbol outline (functions/classes) from LSP or tree-sitter. | tagbar | `:AerialToggle`, keys |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Popup cheatsheet of mappings following a prefix. | — | `VeryLazy` |
| [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim) | Delete a buffer without closing its window/split. | vim-bufkill (`:BD`) | `:Bdelete`, keys |
| [persistence.nvim](https://github.com/folke/persistence.nvim) | Saves your editing session (buffers, splits, tab pages, cwd, folds) per project directory on quit; restore on demand. | `:mksession` | `BufReadPre`, keys |

## Editing

| Plugin | What it does | Replaces | Loads on |
| --- | --- | --- | --- |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Add/change/delete surrounding pairs (`ys`/`cs`/`ds`). | vim-surround | `BufReadPre`, `BufNewFile` |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-insert/delete matching brackets & quotes (tree-sitter aware). | — | `InsertEnter` |
| [vim-visual-multi](https://github.com/mg979/vim-visual-multi) | Sublime-style multiple cursors (`<C-n>`). | vim-multiple-cursors | `BufReadPre`, `BufNewFile` |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump anywhere on screen with search labels; also a Treesitter-node selector and a motion in operator/visual modes (`s`/`S`/`r`/`R`). | vim-easymotion, vim-sneak | `VeryLazy`, keys |

## Git

| Plugin | What it does | Replaces | Loads on |
| --- | --- | --- | --- |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Inline gutter signs for added/changed/removed lines; hunk staging. | vim-gitgutter | `BufReadPre`, `BufNewFile` |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Full-window git diff, merge-conflict and file-history UI. | — | `:Diffview…`, keys |
| [neogit](https://github.com/NeogitOrg/neogit) | Magit-style interactive git UI (stage/commit/branch/push/pull/rebase). | vim-fugitive | `:Neogit`, keys |

## Debugging

| Plugin | What it does | Replaces | Loads on |
| --- | --- | --- | --- |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client — breakpoints, stepping, inspection. `codelldb` drives C/C++/Rust. | nvim-gdb | keys |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Visual debugger panels (scopes, watches, stack, REPL); auto-opens with a session. | — | keys |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Navigable list for diagnostics, references, symbols, quickfix/loclist. | — | `:Trouble`, keys |

> Install the C/C++/Rust debug adapter once with `:MasonInstall codelldb`.

## Appearance & Markdown (pre-existing)

| Plugin | What it does | Loads on |
| --- | --- | --- |
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme (`tokyonight-night`), loaded eagerly at startup. | startup (`priority = 1000`) |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indentation guides with tree-sitter-aware current-scope highlight. | `BufReadPost`, `BufNewFile` |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | In-buffer markdown prettifying (headings, tables, code blocks, callouts). | `ft = markdown` |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser live preview with Mermaid/KaTeX (`<leader>mp`). Needs Node.js. | `:MarkdownPreview…`, `ft = markdown` |

## Dependencies (installed automatically)

These are pulled in by the plugins above and are not configured directly:

| Plugin | Required by |
| --- | --- |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | telescope, neo-tree, diffview, neogit |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim) | neo-tree |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | neo-tree, lualine, bufferline, aerial, trouble, render-markdown |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | nvim-lspconfig |
| [nvim-nio](https://github.com/nvim-neotest/nvim-nio) | nvim-dap-ui |

---

## Key mapping reference

Buffer-local LSP maps are active only where a language server is attached.
`<C-b>…` chords and `<C-p>`/`<C-n>` mirror the plain-vim config.

### Finding (telescope)

| Key | Action |
| --- | --- |
| `<C-p>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` / `<C-b><C-b>` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fs` | Document symbols |
| `<leader>fw` | Grep word under cursor |

### LSP (per buffer)

| Key | Action |
| --- | --- |
| `gd` / `gD` / `gi` | Go to definition / declaration / implementation |
| `grr` | References |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cd` | Line diagnostics (float) |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>ch` | clangd: switch source ↔ header (was `a.vim` `:A`) |

### Navigation & buffers

| Key | Action |
| --- | --- |
| `<C-b><C-t>` | File explorer: toggle |
| `<C-b><C-f>` | File explorer: reveal current file |
| `<leader>e` | File explorer: toggle |
| `<C-b><C-g>` / `<leader>o` | Symbol outline: toggle |
| `<leader>bp` | Pick buffer |
| `<C-b><C-x>` / `<leader>bd` | Delete buffer (keep window) |
| `<Tab>` / `<S-Tab>` | Next / previous buffer (from vimrc) |
| `<leader>?` | Show buffer keymaps (which-key) |

### Session (persistence)

| Key | Action |
| --- | --- |
| `<leader>qs` | Restore session for the current directory |
| `<leader>ql` | Restore the last session |
| `<leader>qd` | Stop saving the current session |

### Editing

| Key | Action |
| --- | --- |
| `ys{motion}{char}` / `cs` / `ds` | Add / change / delete surround |
| `<C-n>` | Multiple cursors: select word, repeat to add cursor |
| `s` | Flash jump: type target chars, then the shown label |
| `S` | Flash Treesitter: label surrounding nodes to select |
| `r` / `R` | Remote flash (operator) / Treesitter search (operator/visual) |
| `<C-s>` | Toggle flash labels during a `/` search |

### Git

| Key | Action |
| --- | --- |
| `<leader>gg` | Neogit status |
| `<leader>gc` | Neogit commit |
| `<leader>gd` | Diffview (working tree) |
| `<leader>gh` | File history (current file) |
| `<leader>gH` | File history (repo) |

### Debugging

| Key | Action |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` / `<F5>` | Continue / start |
| `<leader>do` / `<F10>` | Step over |
| `<leader>di` / `<F11>` | Step into |
| `<leader>dO` / `<S-F11>` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Evaluate expression (normal/visual) |

### Diagnostics (trouble)

| Key | Action |
| --- | --- |
| `<leader>xx` | Diagnostics (workspace) |
| `<leader>xX` | Diagnostics (current buffer) |
| `<leader>xs` | Symbols |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |

### Completion (blink.cmp, insert mode)

| Key | Action |
| --- | --- |
| `<C-y>` | Accept completion |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-Space>` | Open menu / docs |

### Markdown

| Key | Action |
| --- | --- |
| `<leader>mp` | Toggle browser preview (markdown buffers) |

---

## First launch & maintenance

- On first `nvim` launch, lazy.nvim installs all plugins and Mason downloads the
  LSP servers listed above (one-time). Tree-sitter parsers compile via clang.
- Run `:MasonInstall codelldb` once to enable C/C++/Rust debugging.
- Useful commands: `:Lazy` (manage plugins), `:Lazy sync` (install/update/clean),
  `:Mason` (manage tooling), `:checkhealth` (diagnose issues), `:TSUpdate`
  (update parsers).
- External tools used by Telescope — `ripgrep` and `fd` — are installed by the
  Windows bootstrap (`bootstrap.ps1`); a [Nerd Font](https://www.nerdfonts.com/)
  is needed for the file/status icons.
