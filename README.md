# dotfiles

## Installation

### Linux / macOS

Bootstrap and install by running:

`bash -c "$(curl -fsSL https://raw.github.com/joao-fnunes/dotfiles/master/install.sh)"`

### Windows

From an elevated PowerShell 7 (`pwsh`) prompt:

```powershell
irm https://raw.github.com/joao-fnunes/dotfiles/master/install.ps1 | iex
```

Or, if you've already cloned the repo:

```powershell
pwsh -ExecutionPolicy Bypass -File .\install.ps1
```

The Windows bootstrap installs Git, the developer toolchain (Node, .NET, Rust,
Python, CMake, LLVM, Docker Desktop, VS Code + Insiders, Neovim, Windows
Terminal, PowerShell 7, Azure CLI, GitHub CLI, Copilot CLI, psmux, etc.) via
**winget**, sets up **WSL + Ubuntu**, installs the PowerShell modules used by
`profile.ps1`, installs the VS Code extension set, and links the dotfiles
(`gitconfig`, `vimrc`, and the Neovim config directory) into your home folder.

Optional heavy packages (Visual Studio 2022 Enterprise, Windows SDK,
Wireshark, Unity Hub, Cosmos DB Emulator, Vagrant, Dr. Memory, Azure VPN
Client) are gated behind `-IncludeOptional`:

```powershell
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1 -IncludeOptional
```

After a fresh WSL install, reboot, launch Ubuntu once to create your UNIX
user, then run the Linux installer above inside Ubuntu.

#### Symlinks on Windows

Creating symlinks needs either an elevated session (`bootstrap.ps1`
self-elevates) **or** Windows *Developer Mode* (Settings → Privacy & security
→ For developers). If you only need to refresh the links without re-installing
packages:

```powershell
pwsh -File .\bootstrap.ps1 -LinksOnly
```

## Neovim (lazy.nvim)

Neovim uses [**lazy.nvim**](https://github.com/folke/lazy.nvim) for plugin
management. The whole `nvim/` directory in this repo is symlinked to Neovim's
config location (`~/.config/nvim` on Linux, `%LocalAppData%\nvim` on Windows):

```
nvim/
├── init.lua                # sources ~/.vimrc for shared settings, then loads lazy
├── lua/
│   ├── config/lazy.lua     # bootstraps lazy.nvim + loads plugin specs
│   └── plugins/*.lua       # one file per plugin spec
└── lazy-lock.json          # pinned plugin versions (committed)
```

lazy.nvim self-installs into `stdpath("data")` on first `nvim` launch and
auto-installs any missing plugins, so no separate install step is required (the
bootstrap scripts run a best-effort `nvim --headless "+Lazy! sync" +qa` to
pre-warm it). Add plugins by dropping a new spec file in `nvim/lua/plugins/`.

See [`nvim/PLUGINS.md`](nvim/PLUGINS.md) for a full list of the installed
plugins, how each is loaded, and the key mappings they add.

Shared editor settings still live in `vimrc`. **Plain vim** keeps using
[Vundle](https://github.com/VundleVim/Vundle.vim) — its plugin block is gated
behind `!has('nvim')`, so Neovim sources the settings but manages plugins with
lazy.nvim instead. lazy.nvim requires Neovim >= 0.8.

## PowerShell profile (tmux directory tracking)

On Windows the bootstrap script writes a 1-line stub at
`$PROFILE.CurrentUserAllHosts` that dot-sources `profile.ps1` directly from the
repo. If you'd rather do it manually:

```powershell
# Add this line to $PROFILE (typically ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)
. "C:\path\to\dotfiles\profile.ps1"
```
