# PowerShell profile for tmux directory tracking
#
# Link or source this file from your PowerShell profile (i.e., $PROFILE):
#   $env:userprofile\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#
# Example (add to your profile):
#   . "C:\path\to\dotfiles\profile.ps1"

# Read git branch from .git/HEAD directly — avoids spawning git.exe every prompt
function Get-GitBranch {
    $dir = $PWD.Path
    while ($dir) {
        $dotgit = [System.IO.Path]::Combine($dir, '.git')
        if ([System.IO.Directory]::Exists($dotgit)) {
            $gitDir = $dotgit
        } elseif ([System.IO.File]::Exists($dotgit)) {
            # Worktree: .git is a file containing "gitdir: <path>"
            $content = [System.IO.File]::ReadAllText($dotgit).Trim()
            if ($content -match '^gitdir:\s*(.+)$') {
                $gitDir = $Matches[1].Replace('/', '\')
                if (-not [System.IO.Path]::IsPathRooted($gitDir)) {
                    $gitDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($dir, $gitDir))
                }
            } else { return $null }
        } else {
            $parent = [System.IO.Path]::GetDirectoryName($dir)
            if (-not $parent -or $parent -eq $dir) { break }
            $dir = $parent
            continue
        }
        $headFile = [System.IO.Path]::Combine($gitDir, 'HEAD')
        if ([System.IO.File]::Exists($headFile)) {
            $raw = [System.IO.File]::ReadAllText($headFile).Trim()
            if ($raw -match '^ref: refs/heads/(.+)$') { return $Matches[1] }
            if ($raw.Length -ge 7) { return $raw.Substring(0, 7) }
        }
        return $null
    }
    return $null
}

function prompt {
    $loc = $executionContext.SessionState.Path.CurrentLocation.Path
    $branch = Get-GitBranch
    if ($branch) {
        "PS $loc [$branch]`r`n❯ "
    } else {
        "PS $loc`r`n❯ "
    }
}

Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

# Exit with Ctrl+D
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

Set-Alias -Name vim -Value nvim

# clangd compile_commands.json generator. Kept here (in dotfiles) so it works
# across every git worktree without committing it into each repo. Runs against
# whatever worktree you're currently in.
Set-Alias -Name Generate-ClangdDatabase -Value "$PSScriptRoot\Generate-ClangdDatabase.ps1"

. $PSScriptRoot\tmux_profile.ps1

# Lazy-load git-completion: only imported on first git <Tab>
Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    if (-not (Get-Module 'git-completion')) {
        Import-Module git-completion
    }
    Complete-Git -CommandAst $CommandAst -CursorPosition $CursorPosition
}
