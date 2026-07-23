-- Browser-based live markdown preview. Unlike the in-buffer renderer
-- (render-markdown.lua), this renders real Mermaid diagrams, KaTeX math and
-- PlantUML via mermaid.js in your default browser, with synchronized scrolling.
--
-- Requires Node.js (present on this machine). The one-time `build` step runs
-- `yarn install` (fetched via npx, so a separate yarn install isn't needed) in
-- the plugin's app/ dir to fetch the preview server's dependencies. A shell
-- build is used instead of the `vim.fn["mkdp#util#install"]()` function form
-- because lazy.nvim does not source the plugin's autoload before running a
-- function build, which fails with "E117: Unknown function: mkdp#util#install".
--
-- Lazy-loaded on the preview commands and the markdown filetype. `<leader>mp`
-- (leader is Space) toggles the preview from within a markdown buffer.
--
-- By default the preview's github-style CSS caps the content container at 900px
-- (#page-ctn in the plugin's page.css), which wastes most of a widescreen
-- monitor. The plugin has no width option, and g:mkdp_markdown_css *replaces*
-- the content stylesheet rather than extending it, so assets/mkdp-markdown.css
-- is a copy of that stylesheet with a width override appended. Point the plugin
-- at it here. stdpath("config") is the nvim config dir, which is a symlink into
-- this repo (see install.yml), so this resolves to nvim/assets/... on every
-- platform. The variable is read by the preview server at request time, so
-- setting it in init (before the plugin loads) is sufficient.
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  build = "cd app && npx --yes yarn install",
  init = function()
    vim.g.mkdp_markdown_css = vim.fs.joinpath(vim.fn.stdpath("config"), "assets", "mkdp-markdown.css")

    -- Keep the browser tab open when switching away from the markdown buffer.
    -- The plugin default (g:mkdp_auto_close = 1) installs a `BufHidden <buffer>`
    -- autocmd that closes the preview whenever the markdown buffer is hidden --
    -- and merely editing another file hides it -- so the tab dies on every
    -- buffer switch. Disabling it makes the preview persist across switches.
    vim.g.mkdp_auto_close = 0

    -- Instead, tie the tab's lifetime to the buffer: close the preview only when
    -- the markdown buffer is actually deleted/wiped. BufDelete/BufWipeout do not
    -- fire on a plain switch (Neovim's default 'hidden' just hides the buffer),
    -- so this cleanly distinguishes "closed" from "switched away".
    --
    -- rpc#preview_close() sends a `close_page` for bufnr('%') only, so the node
    -- server closes just that buffer's browser tab (clients are keyed by bufnr)
    -- and other previews stay open. But it reads bufnr('%'), which during
    -- BufDelete/BufWipeout is whatever buffer we switched to -- not the one being
    -- closed. nvim_buf_call runs it with the closing buffer current so the right
    -- tab is targeted. The b:MarkdownPreviewToggleBool guard (set when <leader>mp
    -- opens a preview) skips buffers that never previewed, so we don't load the
    -- plugin or disturb an unrelated preview.
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
      group = vim.api.nvim_create_augroup("mkdp_close_on_buf_delete", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].filetype == "markdown" and vim.b[ev.buf].MarkdownPreviewToggleBool == 1 then
          -- BufDelete and BufWipeout both fire for one wipe; clear the flag so
          -- the tab is closed exactly once.
          vim.b[ev.buf].MarkdownPreviewToggleBool = 0
          pcall(vim.api.nvim_buf_call, ev.buf, function()
            vim.fn["mkdp#rpc#preview_close"]()
          end)
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>mp",
      "<cmd>MarkdownPreviewToggle<cr>",
      ft = "markdown",
      desc = "Markdown Preview (browser)",
    },
  },
}
