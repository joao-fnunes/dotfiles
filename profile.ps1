# PowerShell profile for tmux directory tracking
#
# Source this file from your PowerShell profile ($PROFILE):
#   . "C:\path\to\pwsh-tmux\profile.ps1"
#
# This wraps your existing prompt — whatever prompt you had before
# (oh-my-posh, starship, custom, or the default) is preserved.

# Capture the current prompt before we replace it
$__pwshTmux_OriginalPrompt = (Get-Item function:prompt).ScriptBlock
$__pwshTmux_LastCwd = $null

function prompt {
    # When the directory changes, store the WSL-equivalent path as a per-pane
    # tmux user option so splits/new-windows open in the correct directory.
    $cwd = $executionContext.SessionState.Path.CurrentLocation.Path
    if ($cwd -ne $script:__pwshTmux_LastCwd) {
        $script:__pwshTmux_LastCwd = $cwd
        $p = $cwd -replace '\\', '/'
        if ($p -match '^([A-Za-z]):(.*)') {
            $p = "/mnt/$($Matches[1].ToLower())$($Matches[2])"
        }
        if ($env:TMUX_PANE) {
            # Fire-and-forget: don't block the prompt waiting for wsl.exe
            try {
                $psi = [Diagnostics.ProcessStartInfo]::new('wsl.exe',
                    "-e tmux -L pwsh set-option -p -t $($env:TMUX_PANE) @pwsh_cwd `"$p`"")
                $psi.CreateNoWindow = $true
                $psi.UseShellExecute = $false
                $null = [Diagnostics.Process]::Start($psi)
            } catch {}
        }
    }

    # Delegate to the original prompt
    & $__pwshTmux_OriginalPrompt
}
