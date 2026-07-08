-- Native toolchain discovery.
--
-- nvim-treesitter compiles its parsers by invoking a C compiler directly, and
-- other optional native bits (e.g. telescope-fzf-native) need one too. On
-- Windows the bootstrap installs LLVM (winget `LLVM.LLVM`) under
-- C:\Program Files\LLVM, but that package does NOT put clang on PATH, so the
-- compiler is invisible to Neovim's build jobs and `:checkhealth
-- nvim-treesitter` reports "no C compiler found".
--
-- If no compiler is already discoverable, prepend the LLVM bin dir to Neovim's
-- PATH for this session only. It is fully guarded -- it runs solely when no
-- compiler is on PATH AND a clang.exe actually exists at a known location -- so
-- it is a no-op on Linux/macOS and on Windows machines that already expose a
-- compiler. This keeps the config self-contained: no separate PATH edit or
-- shell restart is needed for parser builds to work.
local M = {}

local COMPILERS = { "cc", "gcc", "clang", "cl", "zig" }

-- Known Windows LLVM install locations (winget default + 32-bit fallback).
local WINDOWS_LLVM_BIN = {
  "C:\\Program Files\\LLVM\\bin",
  "C:\\Program Files (x86)\\LLVM\\bin",
}

local function has_compiler()
  for _, cc in ipairs(COMPILERS) do
    if vim.fn.executable(cc) == 1 then
      return true
    end
  end
  return false
end

function M.setup()
  if has_compiler() then
    return
  end

  if vim.fn.has("win32") == 1 then
    for _, dir in ipairs(WINDOWS_LLVM_BIN) do
      if vim.fn.executable(dir .. "\\clang.exe") == 1 then
        vim.env.PATH = dir .. ";" .. vim.env.PATH
        return
      end
    end
  end
end

return M
