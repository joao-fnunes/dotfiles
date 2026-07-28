-- In-buffer markdown rendering: prettifies headings, tables, code blocks,
-- lists, checkboxes and callouts directly inside Neovim (no browser). Used for
-- comfortable day-to-day reading and editing.
--
-- Neovim bundles the `markdown` + `markdown_inline` treesitter parsers, so this
-- plugin's core rendering works even on its own. This config also runs
-- nvim-treesitter (see treesitter.lua), which installs a richer set of markdown
-- queries using the bundled LLVM clang; render-markdown transparently uses
-- whichever parser/queries win on the runtimepath. nvim-web-devicons (pure Lua)
-- supplies the code-block language icons and needs a Nerd Font in your terminal
-- for glyphs.
--
-- Note: this does NOT render Mermaid diagrams -- a ```mermaid block is only
-- styled as a code block. Use markdown-preview.nvim (browser) to see diagrams.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Keep the optional html/latex/yaml renderers off. They add extra in-buffer
  -- prettification (raw HTML, LaTeX math, YAML frontmatter) this setup doesn't
  -- need, and latex/html would require tree-sitter parsers we don't install.
  -- Leaving them off keeps `:checkhealth render-markdown` clean and the view
  -- focused -- use markdown-preview.nvim (browser) for real LaTeX math and
  -- Mermaid. Core rendering (headings, tables, lists, checkboxes, code blocks,
  -- callouts) only needs the markdown + markdown_inline parsers.
  opts = {
    html = { enabled = false },
    latex = { enabled = false },
    yaml = { enabled = false },
  },
  init = function()
    -- render-markdown needs the tree-sitter highlighter active on markdown
    -- buffers. treesitter.lua already starts it via its own FileType autocmd,
    -- but start it here too as a self-contained fallback: the markdown parser
    -- ships with Neovim, so this works even if nvim-treesitter is absent, and
    -- calling vim.treesitter.start twice on a buffer is a harmless no-op.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
