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

Write-Info "Bootstrapping Windows dotfiles..."

Ensure-Chezmoi
chezmoi init https://github.com/$GITHUB_OWNER/$GITHUB_DOTFILES_REPO
chezmoi update
chezmoi apply

Write-Ok "Done."
