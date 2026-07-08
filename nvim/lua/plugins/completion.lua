-- Completion: blink.cmp, a fast, batteries-included completion engine (the
-- lua-native successor to the plain-vim deoplete setup). It ships its own
-- snippet expansion and signature help, so no separate nvim-cmp/LuaSnip stack
-- is needed.
--
-- lspconfig.lua calls blink's get_lsp_capabilities() so servers advertise the
-- richer completion capabilities blink supports.
--
-- Pinned to a tagged release (version = "1.*") on purpose: blink then downloads
-- a prebuilt Rust fuzzy-matcher binary instead of compiling one with cargo,
-- keeping this compiler-light. If the binary is unavailable it transparently
-- falls back to a pure-Lua matcher.
return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    -- "default" preset: <C-y> accepts, <C-n>/<C-p> or arrows navigate. Leaves
    -- <Tab>/<CR> untouched, so it won't fight the buffer-cycling <Tab> map.
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    signature = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
