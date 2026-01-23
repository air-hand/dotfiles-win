# bootstrap.ps1
# - Installs mise (via winget) if missing
# - Installs/updates your global mise config.toml (copied from this repo)
# - Installs/updates your PowerShell profile (copied from this repo, overwrite-safe)
# - Runs `mise install`
#
# Usage:
#   pwsh -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1
#
# Expected files in the same repo:
#   .\mise\config.toml
#   .\powershell\Microsoft.PowerShell_profile.ps1

[CmdletBinding()]
param(
  # Repo paths
  [string]$RepoConfigToml   = (Join-Path $PSScriptRoot "mise\config.toml"),
  [string]$RepoProfilePs1   = (Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"),

  # Targets
  [string]$MiseConfigDir    = (Join-Path $env:USERPROFILE ".config\mise"),
  [string]$PwshProfilePath  = $PROFILE,

  # Behavior
  [switch]$RunInstall       = $true,
  [switch]$BackupExisting   = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[*] $msg" }
function Write-Ok($msg)   { Write-Host "[+] $msg" }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

function Has-Command($name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Ensure-ClaudeCode {
  if (Has-Command "claude") {
    Write-Ok "Claude Code is already installed: $(claude --version)"
    return
  }

  Write-Info "Claude Code not found. Installing via official installer (stable)..."
  & ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable

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

function Ensure-Mise {
  if (Has-Command "mise") {
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

  if ($BackupExisting -and (Test-Path $dst)) {
    $bak = "$dst.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item -Force $dst $bak
    Write-Ok "Backed up existing mise config to: $bak"
  }

  Copy-Item -Force $RepoConfigToml $dst
  Write-Ok "Installed mise config: $dst"

  [Environment]::SetEnvironmentVariable("MISE_CONFIG_DIR", $MiseConfigDir, "User")
  Write-Ok "Set user env: MISE_CONFIG_DIR=$MiseConfigDir"
}

function Ensure-PwshProfile {
  if (-not (Test-Path $RepoProfilePs1)) {
    throw "Repo PowerShell profile not found: $RepoProfilePs1"
  }

  $profileDir = Split-Path -Parent $PwshProfilePath
  New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

  if ($BackupExisting -and (Test-Path $PwshProfilePath)) {
    $bak = "$PwshProfilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item -Force $PwshProfilePath $bak
    Write-Ok "Backed up existing PowerShell profile to: $bak"
  }

  Copy-Item -Force $RepoProfilePs1 $PwshProfilePath
  Write-Ok "Installed PowerShell profile: $PwshProfilePath"
}

function Run-MiseInstall {
  if (-not (Has-Command "mise")) {
    Write-Warn "Skipping mise install: mise command not available in this session."
    return
  }

  Write-Info "Running: mise install"
  mise install
  Write-Ok "mise install done."

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
Ensure-Mise
Ensure-MiseConfig
Ensure-PwshProfile
Ensure-ClaudeCode

if ($RunInstall) {
  Run-MiseInstall
} else {
  Write-Info "RunInstall disabled. You can run `mise install` manually after restarting PowerShell."
}

Write-Ok "Done."
