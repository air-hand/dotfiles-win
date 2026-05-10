# Microsoft.PowerShell_profile.ps1
# Minimal profile for "thin" Windows dotfiles:
# - enable mise shims for this shell
# - (optional) a couple of sane defaults

$profileModulesPath = Join-Path $PSScriptRoot "ProfileModules"
if (Test-Path $profileModulesPath) {
  Get-ChildItem -Path $profileModulesPath -Filter "*.psm1" -File |
    Sort-Object Name |
    ForEach-Object {
      Import-Module $_.FullName -Force -DisableNameChecking
    }
}

# posh-git adds git-aware prompt and tab completion.
if (Get-Module -ListAvailable -Name posh-git) {
  if (-not (Get-Module -Name posh-git)) {
    Import-Module posh-git
  }
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
