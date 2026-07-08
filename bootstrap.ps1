<#
.SYNOPSIS
    Bootstrap a fresh Windows machine with the developer tools and
    dotfiles this repo expects (Windows analog of `bootstrap.yml`).

.DESCRIPTION
    Installs the winget package list, sets up WSL + Ubuntu, installs
    PowerShell modules used by `profile.ps1`, installs VS Code (and
    Insiders) extensions, and links / sources the dotfiles into the
    right places.

    The script self-elevates on launch because most winget packages are
    machine-scope and `wsl --install` needs admin. Mirrors the Linux
    flow where `bootstrap.yml` uses `become: true`.

    All steps are idempotent — re-running is safe and only does the
    work that's still missing.

.PARAMETER SkipWinget
    Skip the winget package install loop.

.PARAMETER SkipWsl
    Skip `wsl --install -d Ubuntu`.

.PARAMETER SkipExtensions
    Skip VS Code / VS Code Insiders extension installs.

.PARAMETER SkipModules
    Skip PowerShell module installs.

.PARAMETER LinksOnly
    Only create the dotfile links / profile stub. Useful for re-running
    on a machine that's already provisioned.

.PARAMETER IncludeOptional
    Also install the optional "heavy" winget packages (Visual Studio
    2022 Community, Windows SDK, Unity Hub, Cosmos DB Emulator,
    Wireshark, Vagrant, Dr. Memory, Web Deploy).

.EXAMPLE
    pwsh -ExecutionPolicy Bypass -File bootstrap.ps1

.EXAMPLE
    pwsh -ExecutionPolicy Bypass -File bootstrap.ps1 -LinksOnly
#>
[CmdletBinding()]
param(
    [switch]$SkipWinget,
    [switch]$SkipWsl,
    [switch]$SkipExtensions,
    [switch]$SkipModules,
    [switch]$LinksOnly,
    [switch]$IncludeOptional
)

$ErrorActionPreference = 'Stop'
$DotfilesRoot = $PSScriptRoot

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Info([string]$Message) {
    Write-Host "    $Message" -ForegroundColor DarkGray
}

function Write-Ok([string]$Message) {
    Write-Host "    [ok] $Message" -ForegroundColor Green
}

function Write-Warn2([string]$Message) {
    Write-Host "    [warn] $Message" -ForegroundColor Yellow
}

function Test-IsAdmin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = [System.Security.Principal.WindowsPrincipal]::new($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-DeveloperMode {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    return (Get-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
}

# ---------------------------------------------------------------------------
# Self-elevate (skip when LinksOnly — symlinks need admin OR Developer Mode,
# but profile-stub + module install are fine as the regular user).
# ---------------------------------------------------------------------------
if (-not $LinksOnly -and -not (Test-IsAdmin)) {
    Write-Host "Re-launching as administrator..." -ForegroundColor Yellow
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
    foreach ($k in $PSBoundParameters.Keys) {
        if ($PSBoundParameters[$k] -is [switch] -and $PSBoundParameters[$k].IsPresent) {
            $argList += "-$k"
        }
    }
    Start-Process -FilePath 'pwsh.exe' -ArgumentList $argList -Verb RunAs -Wait
    exit $LASTEXITCODE
}

# ---------------------------------------------------------------------------
# Winget package list. Pinned to canonical Ids. See plan.md for discovery.
# ---------------------------------------------------------------------------
$WingetCore = @(
    # Source control & shells
    'Git.Git',
    'GitHub.cli',
    'GitHub.Copilot',
    'Microsoft.PowerShell',
    'Microsoft.WindowsTerminal',
    # Editors
    'Microsoft.VisualStudioCode',
    'Microsoft.VisualStudioCode.Insiders',
    'Neovim.Neovim',
    # Language toolchains
    'OpenJS.NodeJS.22',
    'Python.Python.3.12',
    'Microsoft.DotNet.SDK.8',
    'Microsoft.DotNet.SDK.6',
    'Microsoft.DotNet.Framework.DeveloperPack_4',
    'Rustlang.Rustup',
    # Build / native dev
    'Kitware.CMake',
    'LLVM.LLVM',
    # Cloud / DevOps
    'Microsoft.AzureCLI',
    'Docker.DockerDesktop',
    # Customizations
    'marlocarlo.psmux'
)

# Heavy or situational — gated behind -IncludeOptional.
$WingetOptional = @(
    'Microsoft.VisualStudio.2022.Community',
    'Microsoft.WindowsSDK.10.0.26100',
    'Hashicorp.Vagrant',
    'WiresharkFoundation.Wireshark',
    'Microsoft.Azure.CosmosEmulator',
    'Microsoft.WebDeploy',
    'Unity.UnityHub',
    'DynamoRIO.drmemory'
)

# ---------------------------------------------------------------------------
# PowerShell modules — match what profile.ps1 lazy-loads + general utility.
# ---------------------------------------------------------------------------
$PsModules = @(
    @{ Name = 'git-completion';  Scope = 'CurrentUser' },
    @{ Name = 'powershell-yaml'; Scope = 'CurrentUser' },
    @{ Name = 'Az';              Scope = 'CurrentUser' }
)

# ---------------------------------------------------------------------------
# VS Code extension lists. Discovery: filesystem walk of
# ~/.vscode{,-insiders}/extensions (see plan.md). Trailing version /
# platform suffix stripped to obtain canonical IDs.
# ---------------------------------------------------------------------------
$CodeExtensions = @(
    'bierner.markdown-mermaid',
    'bpruitt-goddard.mermaid-markdown-syntax-highlighting',
    'deerawan.vscode-hasher',
    'docker.docker',
    'donjayamanne.githistory',
    'dotjoshjohnson.xml',
    'eamodio.gitlens',
    'mranno.syslog-ng',
    'ms-azure-load-testing.microsoft-testing',
    'ms-azuretools.azure-dev',
    'ms-azuretools.vscode-azure-github-copilot',
    'ms-azuretools.vscode-azure-mcp-server',
    'ms-azuretools.vscode-azureappservice',
    'ms-azuretools.vscode-azurecontainerapps',
    'ms-azuretools.vscode-azurefunctions',
    'ms-azuretools.vscode-azureresourcegroups',
    'ms-azuretools.vscode-azurestaticwebapps',
    'ms-azuretools.vscode-azurestorage',
    'ms-azuretools.vscode-azurevirtualmachines',
    'ms-azuretools.vscode-bicep',
    'ms-azuretools.vscode-containers',
    'ms-azuretools.vscode-cosmosdb',
    'ms-azuretools.vscode-docker',
    'ms-dotnettools.csdevkit',
    'ms-dotnettools.csharp',
    'ms-dotnettools.vscode-dotnet-runtime',
    'ms-mssql.data-workspace-vscode',
    'ms-mssql.mssql',
    'ms-mssql.sql-bindings-vscode',
    'ms-mssql.sql-database-projects-vscode',
    'ms-python.black-formatter',
    'ms-python.debugpy',
    'ms-python.python',
    'ms-python.vscode-pylance',
    'ms-python.vscode-python-envs',
    'ms-sarifvscode.sarif-viewer',
    'ms-toolsai.jupyter',
    'ms-toolsai.jupyter-keymap',
    'ms-toolsai.jupyter-renderers',
    'ms-toolsai.vscode-jupyter-cell-tags',
    'ms-toolsai.vscode-jupyter-slideshow',
    'ms-vscode-remote.remote-containers',
    'ms-vscode-remote.remote-ssh',
    'ms-vscode-remote.remote-ssh-edit',
    'ms-vscode-remote.remote-wsl',
    'ms-vscode-remote.vscode-remote-extensionpack',
    'ms-vscode.azurecli',
    'ms-vscode.cmake-tools',
    'ms-vscode.cpp-devtools',
    'ms-vscode.cpptools',
    'ms-vscode.cpptools-extension-pack',
    'ms-vscode.cpptools-themes',
    'ms-vscode.makefile-tools',
    'ms-vscode.powershell',
    'ms-vscode.remote-explorer',
    'ms-vscode.vscode-copilot-vision',
    'ms-vscode.vscode-node-azure-pack',
    'ms-windows-ai-studio.windows-ai-studio',
    'msysyamamoto.vscode-fluentd',
    'pomdtr.excalidraw-editor',
    'puppet.puppet-vscode',
    'redhat.ansible',
    'redhat.vscode-yaml',
    'rust-lang.rust-analyzer',
    'shopify.ruby-lsp',
    'streetsidesoftware.code-spell-checker',
    'teamsdevapp.vscode-ai-foundry',
    'tyriar.sort-lines',
    'vscode-icons-team.vscode-icons',
    'vscodevim.vim',
    'wholroyd.jinja'
)

$CodeInsidersExtensions = @(
    'ms-azure-load-testing.microsoft-testing',
    'ms-azuretools.azure-dev',
    'ms-azuretools.vscode-azure-github-copilot',
    'ms-azuretools.vscode-azure-mcp-server',
    'ms-azuretools.vscode-azureappservice',
    'ms-azuretools.vscode-azurecontainerapps',
    'ms-azuretools.vscode-azurefunctions',
    'ms-azuretools.vscode-azureresourcegroups',
    'ms-azuretools.vscode-azurestaticwebapps',
    'ms-azuretools.vscode-azurestorage',
    'ms-azuretools.vscode-azurevirtualmachines',
    'ms-azuretools.vscode-cosmosdb',
    'ms-vscode.vscode-copilot-vision',
    'ms-vscode.vscode-node-azure-pack',
    'ms-windows-ai-studio.windows-ai-studio',
    'teamsdevapp.vscode-ai-foundry'
)

# ===========================================================================
# 1. Winget packages
# ===========================================================================
function Install-WingetPackages {
    if ($SkipWinget) { Write-Step 'Skipping winget package installs'; return }
    Write-Step 'Installing winget packages'

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warn2 'winget not found on PATH. Install "App Installer" from the Microsoft Store and re-run.'
        return
    }

    $packages = @($WingetCore)
    if ($IncludeOptional) { $packages += $WingetOptional }

    foreach ($id in $packages) {
        # Idempotency: skip if already present. Exit code is non-zero when
        # the package is NOT installed, so check stdout for the Id.
        $listing = winget list --id $id --exact --accept-source-agreements 2>$null | Out-String
        if ($listing -match [regex]::Escape($id)) {
            Write-Ok "$id already installed"
            continue
        }
        Write-Info "Installing $id ..."
        winget install --id $id --exact `
            --accept-package-agreements --accept-source-agreements `
            --disable-interactivity --silent --source winget
        if ($LASTEXITCODE -ne 0) {
            Write-Warn2 "winget install $id exited with $LASTEXITCODE"
        }
    }
}

# ===========================================================================
# 2. WSL + Ubuntu
# ===========================================================================
function Install-Wsl {
    if ($SkipWsl) { Write-Step 'Skipping WSL install'; return }
    Write-Step 'Installing WSL + Ubuntu'

    # Already provisioned?
    $existing = (& wsl.exe -l -q 2>$null) -replace "`0", '' -split "`r?`n" | Where-Object { $_ }
    if ($existing -contains 'Ubuntu') {
        Write-Ok 'Ubuntu distro already present'
        return
    }

    # wsl --install on recent Windows 11 enables WSL + VirtualMachinePlatform
    # and installs the default Ubuntu distro in one shot. A reboot may be
    # required before the distro can be launched.
    Write-Info 'Running: wsl --install -d Ubuntu'
    wsl --install -d Ubuntu
    if ($LASTEXITCODE -ne 0) {
        Write-Warn2 "wsl --install exited with $LASTEXITCODE — a reboot may be required."
    }
    Write-Info 'After reboot, launch Ubuntu once to create your UNIX user, then'
    Write-Info 'run the existing Linux bootstrap inside Ubuntu:'
    Write-Info '  bash -c "$(curl -fsSL https://raw.github.com/joao-fnunes/dotfiles/master/install.sh)"'
}

# ===========================================================================
# 3. PowerShell modules
# ===========================================================================
function Install-PsModules {
    if ($SkipModules) { Write-Step 'Skipping PowerShell module installs'; return }
    Write-Step 'Installing PowerShell modules'

    # PowerShellGet may need NuGet provider on a fresh box.
    if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Info 'Installing NuGet package provider'
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
    }
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    foreach ($m in $PsModules) {
        if (Get-Module -ListAvailable -Name $m.Name) {
            Write-Ok "$($m.Name) already installed"
            continue
        }
        Write-Info "Installing $($m.Name) ..."
        Install-Module -Name $m.Name -Scope $m.Scope -Force -AllowClobber -AcceptLicense
    }
}

# ===========================================================================
# 4. VS Code extensions
# ===========================================================================
function Install-VsCodeExtensions {
    if ($SkipExtensions) { Write-Step 'Skipping VS Code extension installs'; return }
    Write-Step 'Installing VS Code extensions'

    function _install([string]$exe, [string[]]$ids) {
        $cmd = Get-Command $exe -ErrorAction SilentlyContinue
        if (-not $cmd) { Write-Warn2 "$exe not found on PATH — skipping its extensions"; return }
        $installed = & $exe --list-extensions 2>$null
        foreach ($id in $ids) {
            if ($installed -contains $id) { continue }
            Write-Info "[$exe] Installing $id"
            & $exe --install-extension $id --force | Out-Null
        }
    }

    _install 'code'          $CodeExtensions
    _install 'code-insiders' $CodeInsidersExtensions
}

# ===========================================================================
# 5. Dotfile links + PowerShell profile stub
# ===========================================================================
function New-DotfileLink {
    param(
        [Parameter(Mandatory)] [string]$Source,
        [Parameter(Mandatory)] [string]$Target
    )
    if (-not (Test-Path $Source)) {
        Write-Warn2 "Source missing: $Source — skipping"
        return
    }

    $parent = Split-Path -Parent $Target
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        # Already a symlink to the correct target? Done.
        if ($item.LinkType -eq 'SymbolicLink' -and (Resolve-Path -LiteralPath $item.Target -ErrorAction SilentlyContinue).Path -eq (Resolve-Path -LiteralPath $Source).Path) {
            Write-Ok "$Target -> $Source"
            return
        }
        Write-Info "Replacing existing $Target"
        Remove-Item -LiteralPath $Target -Force -Recurse
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force | Out-Null
        Write-Ok "Linked $Target -> $Source"
    } catch {
        Write-Warn2 "Failed to symlink $Target. Enable Developer Mode or run elevated."
        throw
    }
}

function Set-Links {
    Write-Step 'Linking dotfiles'

    if (-not (Test-IsAdmin) -and -not (Test-DeveloperMode)) {
        Write-Warn2 'Creating symlinks requires admin OR Windows Developer Mode.'
        Write-Warn2 'Enable Developer Mode: Settings > Privacy & security > For developers.'
        throw 'Cannot create symlinks without elevation or Developer Mode.'
    }

    $home_ = [Environment]::GetFolderPath('UserProfile')
    $localAppData = [Environment]::GetFolderPath('LocalApplicationData')

    New-DotfileLink -Source (Join-Path $DotfilesRoot 'gitconfig') -Target (Join-Path $home_ '.gitconfig')
    New-DotfileLink -Source (Join-Path $DotfilesRoot 'vimrc')     -Target (Join-Path $home_ '_vimrc')
    New-DotfileLink -Source (Join-Path $DotfilesRoot 'vimrc')     -Target (Join-Path $home_ '.vimrc')
    # Whole Neovim config dir (init.lua + lua/) is linked; lazy.nvim manages plugins.
    New-DotfileLink -Source (Join-Path $DotfilesRoot 'nvim')      -Target (Join-Path $localAppData 'nvim')
}

function Set-PsProfileStub {
    Write-Step 'Wiring PowerShell profile'

    # $PROFILE.CurrentUserAllHosts is a path under (possibly OneDrive-redirected)
    # Documents. A stub that dot-sources the repo file dodges OneDrive quirks
    # and preserves $PSScriptRoot so tmux_profile.ps1 resolves correctly.
    $profilePath = $PROFILE.CurrentUserAllHosts
    $repoProfile = Join-Path $DotfilesRoot 'profile.ps1'
    $stubLine    = ". `"$repoProfile`""

    $parent = Split-Path -Parent $profilePath
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    if (Test-Path -LiteralPath $profilePath) {
        $current = Get-Content -LiteralPath $profilePath -Raw -ErrorAction SilentlyContinue
        if ($current -and $current.Contains($repoProfile)) {
            Write-Ok "Profile already sources $repoProfile"
            return
        }
        $backup = "$profilePath.bak"
        Copy-Item -LiteralPath $profilePath -Destination $backup -Force
        Write-Info "Existing profile backed up to $backup"
    }

    $stub = @(
        "# Auto-generated by dotfiles/bootstrap.ps1",
        "# Edit the source file at $repoProfile",
        $stubLine
    ) -join "`r`n"
    Set-Content -LiteralPath $profilePath -Value $stub -Encoding UTF8
    Write-Ok "Wrote profile stub at $profilePath"
}

# ===========================================================================
# 6. Neovim plugins (lazy.nvim)
# ===========================================================================
function Install-NvimPlugins {
    Write-Step 'Pre-installing Neovim plugins (lazy.nvim)'

    # lazy.nvim self-installs on first `nvim` launch, so this is best-effort:
    # it just pre-warms the install and generates lazy-lock.json. `nvim` may not
    # be on PATH yet if it was installed by winget in this same session.
    if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
        Write-Warn2 'nvim not found on PATH — skipping. lazy.nvim will self-install on first nvim launch.'
        return
    }

    try {
        & nvim --headless '+Lazy! sync' +qa
        Write-Ok 'lazy.nvim sync complete'
    } catch {
        Write-Warn2 "lazy.nvim sync failed: $($_.Exception.Message). It will self-install on first nvim launch."
    }
}

# ===========================================================================
# Main
# ===========================================================================
Write-Host "Dotfiles bootstrap (Windows)" -ForegroundColor Magenta
Write-Host "Repo root: $DotfilesRoot"

if ($LinksOnly) {
    Set-Links
    Set-PsProfileStub
    Install-NvimPlugins
} else {
    Install-WingetPackages
    Install-Wsl
    Install-PsModules
    Install-VsCodeExtensions
    Set-Links
    Set-PsProfileStub
    Install-NvimPlugins
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Reboot if WSL was just installed."
Write-Host "  2. Launch Ubuntu once to create your UNIX user."
Write-Host "  3. Inside Ubuntu, run the Linux bootstrap:"
Write-Host '       bash -c "$(curl -fsSL https://raw.github.com/joao-fnunes/dotfiles/master/install.sh)"'
Write-Host "  4. Optional: install the `'agency`' CLI manually (no public source)."
