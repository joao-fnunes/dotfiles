-- LSP: real code intelligence (go-to-definition, references, hover, rename,
-- code actions, diagnostics) via language servers. This replaces the old
-- deoplete-clang / vim-rtags stack from the plain-vim (Vundle) config.
--
-- Wiring:
--   * mason.nvim (mason.lua) downloads the server binaries.
--   * mason-lspconfig bridges Mason <-> lspconfig and, on Neovim 0.11,
--     auto-enables each installed server via vim.lsp.enable().
--   * nvim-lspconfig ships the base server configs that vim.lsp.config()/enable()
--     pick up. We layer capabilities + per-server tweaks on top.
--
-- Keymaps are attached per-buffer from an LspAttach autocmd, so they only exist
-- where a server is actually running.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
  },
  config = function()
    -- Diagnostics presentation: inline virtual text, gutter signs and rounded
    -- float borders.
    vim.diagnostic.config({
      virtual_text = true,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })

    -- Completion capabilities. blink.cmp (completion.lua) advertises richer
    -- capabilities than the built-in client; pull them in when it is present,
    -- otherwise fall back to the stock capabilities. The pcall keeps this file
    -- valid even before blink.cmp is installed.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    -- Apply capabilities to every server, then layer server-specific config.
    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        -- Let :ClangdSwitchSourceHeader / <leader>ch drive header edits instead
        -- of clangd auto-inserting includes.
        "--header-insertion=never",
      },
    })

    -- lua_ls: teach it the `vim` global so editing this very config is clean.
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "clangd",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "powershell_es",
      },
    })

    -- clangd's switch-source-header LSP extension: the modern replacement for
    -- the a.vim :A command. Jumps between a .cpp/.cc and its matching header.
    local function switch_source_header(bufnr)
      local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
      if not client then
        vim.notify("clangd is not attached to this buffer", vim.log.levels.WARN)
        return
      end
      local params = vim.lsp.util.make_text_document_params(bufnr)
      client:request("textDocument/switchSourceHeader", params, function(err, result)
        if err then
          vim.notify("switchSourceHeader: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        if not result then
          vim.notify("No corresponding source/header file", vim.log.levels.WARN)
          return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
      end, bufnr)
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lspconfig-attach", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("grr", vim.lsp.buf.references, "References")
        map("K", vim.lsp.buf.hover, "Hover docs")
        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
        map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

        if client and client.name == "clangd" then
          map("<leader>ch", function() switch_source_header(bufnr) end, "Switch source/header")
        end
      end,
    })
  end,
}
