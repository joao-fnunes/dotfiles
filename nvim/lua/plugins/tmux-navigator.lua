-- vim-tmux-navigator: makes one set of keys glide across Neovim splits AND tmux
-- panes as a single grid, so moving focus no longer means thinking about which
-- program owns the boundary. Bound here to <M-hjkl> to match the prefix-free
-- Alt+hjkl pane switching already in tmux.conf (whose four `bind -n M-hjkl` lines
-- are replaced with vim-aware `if-shell` versions: when a vim/nvim process owns
-- the pane the keystroke is forwarded INTO Neovim so these maps run; at an edge
-- split :TmuxNavigate* calls `tmux select-pane` to cross into the neighbouring
-- tmux pane instead of stopping).
--
-- Gotchas:
--   * `tmux_navigator_no_mappings = 1` (set in init, before the plugin loads)
--     suppresses the plugin's default <C-hjkl>/<C-\> maps so ONLY our <M-hjkl>
--     bindings exist and nothing shadows <C-l> redraw etc.
--   * lazy-loaded on the <M-hjkl> keys (and the :TmuxNavigate* commands); the
--     first press pulls the plugin in, thereafter it is a direct command call.
--   * With no tmux around (e.g. Neovim in a plain terminal) the same commands
--     fall back to ordinary `wincmd h/j/k/l`, so the keys stay useful everywhere.
return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<M-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left split / tmux pane" },
    { "<M-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to below split / tmux pane" },
    { "<M-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to above split / tmux pane" },
    { "<M-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right split / tmux pane" },
  },
}
