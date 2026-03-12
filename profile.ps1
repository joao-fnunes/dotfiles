# PowerShell profile for tmux directory tracking (OSC 7)
#
# Link or source this file from your PowerShell profile (i.e., $PROFILE):
#   $env:userprofile\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#
# Example (add to your profile):
#   . "C:\path\to\dotfiles\profile.ps1"

function prompt {
    # Build OSC 7 escape sequence so tmux can track the current working directory
    $loc = $executionContext.SessionState.Path.CurrentLocation
    $p = "$loc" -replace '\\', '/'
    if ($p -match '^([A-Za-z]):(.*)') {
        $p = "/mnt/$($Matches[1].ToLower())$($Matches[2])"
    }
    $osc7 = "`e]7;file://localhost$p`a"

    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        "${osc7}PS $loc [$branch]`r`n❯ "
    } else {
        "${osc7}PS $loc`r`n❯ "
    }
}
