# bootstrap.ps1
# - Installs chezmoi & apply
#
# Usage:
#   pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1


[CmdletBinding()]
param(
  [string]$GITHUB_OWNER  = "air-hand"
  , [string]$GITHUB_DOTFILES_REPO   = "dotfiles-win"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$commonModulePath = Join-Path $PSScriptRoot "Documents\powershell\Dotfiles.Common.psm1"
Import-Module $commonModulePath -Force -DisableNameChecking

function Ensure-ClaudeCode {
  if (Has-Command "claude") {
    Write-Ok "Claude Code is already installed: $(claude --version)"
    return
  }

  Write-Info "Claude Code not found. Installing via official installer..."
  irm https://claude.ai/install.ps1 | iex

  if (Has-Command "claude") {
    Write-Ok "Claude Code installed: $(claude --version)"
  } else {
    Write-Warn "Claude Code installed but not visible in current session (PATH refresh needed)."
  }
}

function Ensure-WinGet {
  if (Has-Command "winget") { return }
  throw "winget was not found. Install App Installer (Microsoft Store) or install mise via your preferred method, then re-run."
}

function Ensure-Chezmoi {
  if (Has-Command "chezmoi") {
    return
  }
  Write-Info "chezmoi not found. installing"
  winget install -e --id twpayne.chezmoi
  if (-not(Has-Command "chezmoi")) {
    Write-Warn "installed chezmoi, but not in PATH. refresh current shell."
  }
}

function Ensure-Mise {
  if (Has-Command "mise") {
    Write-Info "Updating mise (self-update)..."
    mise self-update -y
    Write-Ok "mise is already installed: $(mise --version)"
    return
  }

  Write-Info "mise not found. Installing via winget (id: jdx.mise)..."
  Ensure-WinGet

  winget install -e --id jdx.mise

  if (-not (Has-Command "mise")) {
    Write-Warn "mise installed but not visible in current session (PATH refresh needed). Restart PowerShell and re-run, or continue if you know it's installed."
  } else {
    Write-Ok "mise installed: $(mise --version)"
  }
}

function Ensure-MiseConfig {
  if (-not (Test-Path $RepoConfigToml)) {
    throw "Repo config.toml not found: $RepoConfigToml"
  }

  New-Item -ItemType Directory -Force -Path $MiseConfigDir | Out-Null
  $dst = Join-Path $MiseConfigDir "config.toml"

  Copy-Item -Force $RepoConfigToml $dst
  Write-Ok "Installed mise config: $dst"

  [Environment]::SetEnvironmentVariable("MISE_CONFIG_DIR", $MiseConfigDir, "User")
  Write-Ok "Set user env: MISE_CONFIG_DIR=$MiseConfigDir"
}

function Ensure-LocalBinPath {
  $localBin = Join-Path $env:USERPROFILE ".local\bin"
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ([string]::IsNullOrWhiteSpace($userPath)) {
    $newPath = $localBin
  } else {
    $pathParts = $userPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($pathParts -notcontains $localBin) {
      $pathParts += $localBin
    }
    $newPath = ($pathParts -join ';')
  }
  if ($newPath -ne $userPath) {
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Ok "Set user env: Path+=${localBin}"
  }
}

function Ensure-PwshProfile {
  Write-Info $PwshProfilePath
#  $profileDir = Split-Path -Parent $PwshProfilePath
#  New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
#
#  Copy-Item -Force $RepoProfilePs1 $PwshProfilePath
#  Write-Ok "Installed PowerShell profile: $PwshProfilePath"
}

function Run-MiseInstall {
  if (-not (Has-Command "mise")) {
    Write-Warn "Skipping mise install: mise command not available in this session."
    return
  }

  Write-Info "Running: mise install"
  mise install
  Write-Ok "mise install done."

  Write-Info "Running: mise prune (removing unused tool versions)..."
  mise prune --yes
  Write-Ok "mise prune done."

  Write-Info "Quick check (may require a new shell for shims to take effect):"
  try { mise --version | Write-Host } catch {}
  foreach ($cmd in @("gh", "codex", "claude")) {
    try {
      if (Has-Command $cmd) {
        Write-Host ("- {0}: {1}" -f $cmd, (& $cmd --version 2>$null))
      } else {
        Write-Host ("- {0}: (not on PATH yet)" -f $cmd)
      }
    } catch {
      Write-Warn "Failed to run '$cmd --version' (tool may not be installed via config, or needs a new shell)."
    }
  }

  Write-Info "NOTE: Restart PowerShell so profile + env vars take effect."
}

Write-Info "Bootstrapping Windows dotfiles (mise)..."
Ensure-Chezmoi
chezmoi init https://github.com/$GITHUB_OWNER/$GITHUB_DOTFILES_REPO
chezmoi update
chezmoi apply

#Ensure-Mise
#Ensure-MiseConfig
#Ensure-PwshProfile
#Ensure-LocalBinPath
#
#Run-MiseInstall

Ensure-ClaudeCode

Write-Ok "Done."
