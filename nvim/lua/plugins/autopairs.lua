-- nvim-autopairs: automatically inserts the closing half of brackets, quotes
-- and parentheses as you type, and deletes both halves together. Treesitter-
-- aware so it won't add a pair inside, e.g., a string or comment where it
-- shouldn't. Loads on first insert to keep startup lean.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
  },
}
