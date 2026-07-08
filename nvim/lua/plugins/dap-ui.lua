-- nvim-dap-ui: the visual front-end for nvim-dap -- scopes/variables, watches,
-- call stack, breakpoints and REPL laid out in side panels. It opens
-- automatically when a debug session starts and closes when it ends.
-- nvim-nio is its required async I/O library.
return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
  },
  keys = {
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
    { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
  end,
}
