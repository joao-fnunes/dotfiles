<#
.SYNOPSIS
    One-liner entry point for bootstrapping a fresh Windows machine
    (analog of Linux `install.sh`).

.DESCRIPTION
    Run from a totally bare Windows install:

        irm https://raw.github.com/joao-fnunes/dotfiles/master/install.ps1 | iex

    Or, if you've already cloned the repo:

        pwsh -ExecutionPolicy Bypass -File install.ps1

    Steps:
      1. Confirm winget is available (ships with Win10 1809+ and Win11).
      2. Install git via winget if missing.
      3. Clone the dotfiles repo to ~\projects\dotfiles (or use the
         existing checkout if this script is being run from one).
      4. Hand off to `bootstrap.ps1`.
#>
[CmdletBinding()]
param(
    [string]$RepoUrl  = 'https://github.com/joao-fnunes/dotfiles.git',
    [string]$CloneDir = (Join-Path $env:USERPROFILE 'projects\dotfiles'),
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$BootstrapArgs
)

$ErrorActionPreference = 'Stop'

function Test-Cmd([string]$Name) { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

Write-Host "Dotfiles installer (Windows)" -ForegroundColor Magenta

# 1. winget sanity check
if (-not (Test-Cmd 'winget')) {
    Write-Host "winget not found." -ForegroundColor Yellow
    Write-Host "Install 'App Installer' from the Microsoft Store and re-run:" -ForegroundColor Yellow
    Write-Host "  https://apps.microsoft.com/detail/9NBLGGH4NNS1"
    exit 1
}

# 2. git
if (-not (Test-Cmd 'git')) {
    Write-Host "Installing Git via winget..." -ForegroundColor Cyan
    winget install --id Git.Git --exact `
        --accept-package-agreements --accept-source-agreements `
        --disable-interactivity --silent --source winget
    # Refresh PATH for the current session so the just-installed `git` resolves.
    $env:PATH = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not (Test-Cmd 'git')) {
        Write-Host "Git install completed but `git` is still not on PATH. Open a new terminal and re-run." -ForegroundColor Yellow
        exit 1
    }
}

# 3. Clone (or use this script's own folder if it lives inside the repo)
$bootstrap = Join-Path $PSScriptRoot 'bootstrap.ps1'
if (Test-Path $bootstrap) {
    $repoDir = $PSScriptRoot
} else {
    if (-not (Test-Path $CloneDir)) {
        Write-Host "Cloning $RepoUrl -> $CloneDir" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path (Split-Path $CloneDir -Parent) -Force | Out-Null
        git clone $RepoUrl $CloneDir
    } else {
        Write-Host "Existing checkout at $CloneDir — pulling latest" -ForegroundColor Cyan
        git -C $CloneDir pull --ff-only
    }
    $repoDir = $CloneDir
}

# 4. Hand off to bootstrap.ps1
$bootstrap = Join-Path $repoDir 'bootstrap.ps1'
Write-Host "Running $bootstrap" -ForegroundColor Cyan
& pwsh -NoProfile -ExecutionPolicy Bypass -File $bootstrap @BootstrapArgs
exit $LASTEXITCODE
