Set-StrictMode -Version Latest

function Write-Info($Message) {
  Write-Host "[*] $Message"
}

function Write-Ok($Message) {
  Write-Host "[+] $Message"
}

function Write-Warn($Message) {
  Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Has-Command($Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function Write-Info, Write-Ok, Write-Warn, Has-Command
