# bootstrap.ps1
# - Installs chezmoi & apply
#
# Usage:
#   pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1


[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$commonModulePath = Join-Path $PSScriptRoot "Documents\PowerShell\ProfileModules\Dotfiles.Common.psm1"
Import-Module $commonModulePath -Force -DisableNameChecking

function Ensure-Chezmoi {
  if (Has-Command "chezmoi") {
    return
  }
  Write-Info "chezmoi not found. installing"
  winget install -e --id twpayne.chezmoi --accept-package-agreements --accept-source-agreements --silent
  $machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
  $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
  $seenPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  $pathParts = foreach ($path in @($env:PATH, $userPath, $machinePath) -split [regex]::Escape([IO.Path]::PathSeparator)) {
    if (-not [string]::IsNullOrWhiteSpace($path) -and $seenPaths.Add($path)) {
      $path
    }
  }
  $env:PATH = $pathParts -join [IO.Path]::PathSeparator

  if (-not(Has-Command "chezmoi")) {
    throw "installed chezmoi, but chezmoi is still not in PATH."
  }
}

Write-Info "Bootstrapping Windows dotfiles..."

Ensure-Chezmoi
chezmoi init --apply --source $PSScriptRoot

Write-Ok "Done."
