-- vim-visual-multi: Sublime-style multiple cursors -- the maintained successor
-- to vim-multiple-cursors from the plain-vim config. Press <C-n> in normal mode
-- to select the word under the cursor and again to add a cursor at the next
-- match; <C-Down>/<C-Up> add vertical cursors. It only maps <C-n> in
-- normal/visual mode, so it doesn't clash with blink.cmp's insert-mode <C-n>.
return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = { "BufReadPre", "BufNewFile" },
}
