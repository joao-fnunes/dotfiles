-- Which-key: pops up a searchable cheatsheet of the mappings that follow a
-- prefix (e.g. after pressing <leader>), so the growing set of leader maps in
-- this config stays discoverable. The group labels below just give the prefixes
-- friendly names in that popup.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>c", group = "code" },
      { "<leader>b", group = "buffer" },
      { "<leader>x", group = "diagnostics" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer keymaps (which-key)",
    },
  },
}
