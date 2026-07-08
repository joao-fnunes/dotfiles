-- nvim-dap: Debug Adapter Protocol client -- interactive debugging (breakpoints,
-- stepping, variable inspection) inside Neovim, replacing the plain-vim nvim-gdb
-- setup. The visual panels come from nvim-dap-ui (dap-ui.lua).
--
-- Adapter: codelldb (LLVM's debugger) drives C/C++/Rust here. Install it once
-- with `:MasonInstall codelldb`; Mason puts it on PATH. Debug maps live under
-- the <leader>d "debug" prefix, with F5/F10/F11 for the common step loop.
return {
  "mfussenegger/nvim-dap",
  dependencies = { "mason-org/mason.nvim" },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<F5>", function() require("dap").continue() end, desc = "Debug: continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
    { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },
  },
  config = function()
    local dap = require("dap")

    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

    -- codelldb is resolved off PATH (Mason prepends its bin dir, and PATHEXT
    -- picks up the .cmd shim on Windows).
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = "codelldb",
        args = { "--port", "${port}" },
      },
    }

    local codelldb_launch = {
      {
        name = "Launch (codelldb)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
    dap.configurations.c = codelldb_launch
    dap.configurations.cpp = codelldb_launch
    dap.configurations.rust = codelldb_launch

    -- Give the debug prefix a friendly label in the which-key popup.
    pcall(function()
      require("which-key").add({ { "<leader>d", group = "debug" } })
    end)
  end,
}
