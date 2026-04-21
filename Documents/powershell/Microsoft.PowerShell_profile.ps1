# Microsoft.PowerShell_profile.ps1
# Minimal profile for "thin" Windows dotfiles:
# - enable mise shims for this shell
# - (optional) a couple of sane defaults

$commonModulePath = Join-Path $PSScriptRoot "Dotfiles.Common.psm1"
if (Test-Path $commonModulePath) {
  Import-Module $commonModulePath -Force -DisableNameChecking
}

# Enable mise shims (so `gh`, `codex`, etc. resolve via mise)
mise activate pwsh | Out-String | Invoke-Expression

# --- Optional quality-of-life (safe to delete) ---
# Better history/search behavior
if (Get-Module -ListAvailable -Name PSReadLine) {
  if (-not (Get-Module -Name PSReadLine)) {
    Import-Module PSReadLine
  }
  Set-PSReadLineOption -EditMode Windows
  if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
  }
  Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

# Make UTF-8 output more consistent in modern tooling
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# Convenience aliases (optional)
Set-Alias ll Get-ChildItem -Option AllScope
