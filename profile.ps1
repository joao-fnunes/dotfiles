# PowerShell profile for tmux directory tracking
#
# Link or source this file from your PowerShell profile (i.e., $PROFILE):
#   $env:userprofile\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#
# Example (add to your profile):
#   . "C:\path\to\dotfiles\profile.ps1"

function prompt {
    $loc = $executionContext.SessionState.Path.CurrentLocation

    # Write WSL-equivalent path for tmux to read when splitting panes
    $p = "$loc" -replace '\\', '/'
    if ($p -match '^([A-Za-z]):(.*)') {
        $p = "/mnt/$($Matches[1].ToLower())$($Matches[2])"
    }
    try { [IO.File]::WriteAllText("$env:USERPROFILE\.tmux_pwsh_cwd", $p) } catch {}

    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        "PS $loc [$branch]`r`n❯ "
    } else {
        "PS $loc`r`n❯ "
    }
}
