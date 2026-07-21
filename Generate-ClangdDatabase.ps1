<#
.SYNOPSIS
Generates a clangd-compatible compile_commands.json from the CMake File API.

.DESCRIPTION
Some CMake projects configure with the "Visual Studio 17 2022" generator,
which never writes a compile_commands.json (only the Makefile/Ninja generators
honor CMAKE_EXPORT_COMPILE_COMMANDS). clangd (the C/C++ language server used by
editors such as VS Code and Neovim) needs that database to resolve includes,
defines and flags.

Rather than fight the repo's VS-generator coupling with a parallel Ninja build,
this script reads the CMake File API "codemodel" that the normal
configure already produces, and synthesizes a compile database with the exact
per-target include paths, preprocessor defines and compile flags from the real
build. The compiler in each entry is cl.exe, so clangd runs in clang-cl mode and
matches the MSVC translation unit as closely as clangd can.

Output is written to <repo>/build/compile_commands.json, which is git-ignored and
auto-discovered by clangd (it searches each source file's ancestors and their
"build/" subdirectories).

This script is repo-location-independent: it detects the current git worktree via
"git rev-parse --show-toplevel", so a single copy (e.g. kept in your dotfiles and
exposed through the Generate-ClangdDatabase alias) serves every worktree.

.PARAMETER PresetName
CMake configure preset whose build tree to read. Default: default.

.PARAMETER Config
Multi-config configuration to extract. Default: Debug (matches build.ps1).

.PARAMETER Configure
Run "cmake --preset <PresetName>" first to (re)generate the File API reply.
Otherwise the most recent existing reply is used.

.EXAMPLE
# Run from inside any CMake git worktree (repo root is auto-detected).
# If already configured, this just (re)writes build\compile_commands.json:
Generate-ClangdDatabase

.EXAMPLE
# One-shot from a fresh worktree: (re)configure the preset, then emit the database.
Generate-ClangdDatabase -Configure
#>
[CmdletBinding()]
param(
    [string]$PresetName = "default",
    [ValidateSet("Debug", "Release", "MinSizeRel", "RelWithDebInfo")]
    [string]$Config = "Debug",
    # Flags dropped from every entry: codegen/policy/ABI flags that are irrelevant
    # to clangd's parsing and actively harm it:
    #   /WX, -WX      turn clang's stricter -Wmicrosoft-* warnings into red errors
    #   /Zc:wchar_t-  aliases wchar_t to unsigned short, which makes clang report
    #                 Boost's integer_traits<wchar_t>/<unsigned short> as a
    #                 redefinition (MSVC tolerates it)
    # Sanitizer flags (/fsanitize-coverage=*, -fsanitize=address) are stripped in
    # the loop below because clang-cl rejects -fsanitize=address next to the debug
    # DLL runtime (-MDd) and aborts the whole translation unit.
    [string[]]$RemoveFlags = @('/WX', '-WX', '/Zc:wchar_t-'),
    [switch]$Configure
)

$ErrorActionPreference = 'Stop'

# This script lives in your dotfiles (outside the project repo) and operates on
# whatever git worktree you're currently in. Resolve that worktree's root; for
# linked worktrees `git rev-parse --show-toplevel` returns the worktree's own root.
$repoRoot = & git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
    throw "Not inside a git repository/worktree. cd into the project worktree first."
}
$repoRoot = (Resolve-Path $repoRoot.Trim()).Path
if (-not (Test-Path (Join-Path $repoRoot 'CMakePresets.json'))) {
    throw "No CMakePresets.json under '$repoRoot' - run this from inside the project worktree."
}
$binRoot = Join-Path $repoRoot "out\build\$PresetName"
$apiDir = Join-Path $binRoot ".cmake\api\v1"
$queryDir = Join-Path $apiDir "query"
$replyDir = Join-Path $apiDir "reply"

# 1) Ensure the codemodel query exists so this (and future) configures emit a reply.
New-Item -ItemType Directory -Force -Path $queryDir | Out-Null
$queryFile = Join-Path $queryDir "codemodel-v2"
if (-not (Test-Path $queryFile)) {
    New-Item -ItemType File -Force -Path $queryFile | Out-Null
    Write-Host "Added CMake File API query: $queryFile"
}

# 2) Optionally (re)configure to refresh the reply.
if ($Configure -or -not (Test-Path $replyDir)) {
    if (-not (Get-Command cmake.exe -ErrorAction Ignore)) {
        throw "cmake.exe not found on PATH. Run from a shell where CMake is available."
    }
    Write-Host "Configuring '$PresetName' to generate the File API reply..."
    Push-Location $repoRoot
    try { cmake --preset $PresetName | Out-Host }
    finally { Pop-Location }
}

if (-not (Test-Path $replyDir)) {
    throw "No File API reply at $replyDir. Configure the '$PresetName' preset first (e.g. .\build.ps1 or 'cmake --preset $PresetName'), then re-run this script."
}

# 3) Load the codemodel index and select the requested configuration.
$index = Get-ChildItem (Join-Path $replyDir "codemodel-v2-*.json") | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $index) { throw "No codemodel reply found under $replyDir." }
$codemodel = Get-Content $index.FullName -Raw | ConvertFrom-Json

$sourceRoot = $codemodel.paths.source
$buildRoot = $codemodel.paths.build

$configuration = $codemodel.configurations | Where-Object { $_.name -eq $Config } | Select-Object -First 1
if (-not $configuration) {
    $available = ($codemodel.configurations | ForEach-Object { $_.name }) -join ", "
    throw "Configuration '$Config' not found. Available: $available"
}

# 4) Walk every target's compile groups and emit one entry per compiled source.
$entries = [System.Collections.Generic.List[object]]::new()
$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($targetRef in $configuration.targets) {
    $targetPath = Join-Path $replyDir $targetRef.jsonFile
    if (-not (Test-Path $targetPath)) { continue }
    $target = Get-Content $targetPath -Raw | ConvertFrom-Json
    if (-not $target.compileGroups) { continue }

    foreach ($source in $target.sources) {
        if ($null -eq $source.compileGroupIndex) { continue }
        $group = $target.compileGroups[$source.compileGroupIndex]
        if ($group.language -notin @("C", "CXX")) { continue }

        $fileAbs = if ([System.IO.Path]::IsPathRooted($source.path)) { $source.path } else { "$sourceRoot/$($source.path)" }
        $fileAbs = $fileAbs -replace '\\', '/'
        if (-not $seen.Add($fileAbs)) { continue }

        # Keep the real build's flags, but drop those that break/pollute clangd.
        $flagTokens = [System.Collections.Generic.List[string]]::new()
        foreach ($fragment in $group.compileCommandFragments) {
            foreach ($token in ($fragment.fragment -split '\s+')) {
                if ([string]::IsNullOrWhiteSpace($token)) { continue }
                if ($RemoveFlags -contains $token) { continue }
                if ($token -like '/fsanitize-coverage=*') { continue }
                if ($token -eq '-fsanitize=address' -or $token -eq '/fsanitize=address') { continue }
                $flagTokens.Add($token)
            }
        }
        $flags = $flagTokens -join ' '
        $defs = ($group.defines  | ForEach-Object { '/D"' + $_.define + '"' }) -join ' '
        $incs = ($group.includes | ForEach-Object { '/I"' + ($_.path -replace '\\', '/') + '"' }) -join ' '

        $command = "cl.exe $flags $defs $incs /c `"$fileAbs`""

        $entries.Add([ordered]@{
                directory = $buildRoot
                command   = $command
                file      = $fileAbs
            })
    }
}

if ($entries.Count -eq 0) { throw "No compilable C/C++ sources found in the '$Config' configuration." }

# 5) Write the database where clangd auto-discovers it (git-ignored build/).
$outDir = Join-Path $repoRoot "build"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outFile = Join-Path $outDir "compile_commands.json"
$entries | ConvertTo-Json -Depth 4 | Set-Content -Path $outFile -Encoding UTF8

Write-Host "Wrote $($entries.Count) entries to $outFile"
Write-Host "clangd will auto-discover it (build/ subdirectory of the repo root)."
