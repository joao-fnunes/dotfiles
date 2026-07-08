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
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  build = "cd app && npx --yes yarn install",
  keys = {
    {
      "<leader>mp",
      "<cmd>MarkdownPreviewToggle<cr>",
      ft = "markdown",
      desc = "Markdown Preview (browser)",
    },
  },
}
