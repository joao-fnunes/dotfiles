-- In-buffer markdown rendering: prettifies headings, tables, code blocks,
-- lists, checkboxes and callouts directly inside Neovim (no browser). Used for
-- comfortable day-to-day reading and editing.
--
-- Zero external tooling on this setup: Neovim 0.11 already bundles the
-- `markdown` + `markdown_inline` treesitter parsers, so nvim-treesitter and a
-- C compiler are NOT required. nvim-web-devicons (pure Lua) supplies the
-- code-block language icons and needs a Nerd Font in your terminal for glyphs.
--
-- Note: this does NOT render Mermaid diagrams -- a ```mermaid block is only
-- styled as a code block. Use markdown-preview.nvim (browser) to see diagrams.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- html/latex/yaml rendering needs tree-sitter parsers that Neovim does NOT
  -- bundle, and this machine has no C compiler to build them, so disable those
  -- optional features to keep `:checkhealth render-markdown` clean. Core
  -- rendering (headings, tables, lists, checkboxes, code blocks, callouts)
  -- uses the bundled markdown + markdown_inline parsers.
  opts = {
    html = { enabled = false },
    latex = { enabled = false },
    yaml = { enabled = false },
  },
  init = function()
    -- render-markdown needs the tree-sitter highlighter active on markdown
    -- buffers. This config has no nvim-treesitter, so start it explicitly --
    -- the markdown parser ships with Neovim, so no compilation is needed.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
