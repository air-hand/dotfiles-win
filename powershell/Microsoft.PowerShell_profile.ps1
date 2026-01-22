# Microsoft.PowerShell_profile.ps1
# Minimal profile for "thin" Windows dotfiles:
# - enable mise shims for this shell
# - (optional) a couple of sane defaults

# Enable mise shims (so `gh`, `codex`, `claude`, etc. resolve via mise)
mise activate pwsh | Out-String | Invoke-Expression

# --- Optional quality-of-life (safe to delete) ---
# Better history/search behavior
if (Get-Module -ListAvailable -Name PSReadLine) {
  Import-Module PSReadLine
  Set-PSReadLineOption -EditMode Windows
  Set-PSReadLineOption -PredictionSource History
  Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

# Make UTF-8 output more consistent in modern tooling
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# Convenience aliases (optional)
Set-Alias ll Get-ChildItem -Option AllScope
