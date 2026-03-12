# dotfiles

## Installation

Bootstrap and install by running:

`bash -c "$(curl -fsSL https://raw.github.com/joao-fnunes/dotfiles/master/install.sh)"`

## PowerShell profile (tmux directory tracking)

To enable "same directory" when splitting panes or opening new windows in the
PowerShell tmux config (`pwsh_tmux.conf`), source `profile.ps1` from your
PowerShell profile:

```powershell
# Add this line to $PROFILE (typically ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)
. "C:\path\to\dotfiles\profile.ps1"
```

Requires **tmux 3.3+** for native OSC 7 support.
