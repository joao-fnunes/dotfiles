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
