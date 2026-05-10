Set-StrictMode -Version Latest

Function Get-VSInstallerDirPath() {
    return (Join-Path "${Env:ProgramFiles(x86)}" "Microsoft Visual Studio\Installer")
}

Function Add-VSInstallerDirToPathEnv() {
    $installerDir = Get-VSInstallerDirPath
    if (-not (Test-Path -LiteralPath $installerDir -PathType Container)) {
        return
    }

    $paths = $Env:PATH -split [System.IO.Path]::PathSeparator
    if ($paths -notcontains $installerDir) {
        $Env:PATH = ($installerDir, $Env:PATH) -join [System.IO.Path]::PathSeparator
    }
}

Function Get-VSWherePath() {
    $command = Get-Command "vswhere.exe" -CommandType Application -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $vswhere = Join-Path (Get-VSInstallerDirPath) "vswhere.exe"
    if (-not (Test-Path -LiteralPath $vswhere -PathType Leaf)) {
        throw "vswhere.exe not found."
    }

    return $vswhere
}

Function Get-VisualStudioPath([string]$version="17.0,18.0", [string]$vsconfig_path=$null) {
    $vswhere = Get-VSWherePath
    $arguments = @(
        "-products", "*",
        "-version", $version,
        "-property", "installationPath"
    )

    if ($vsconfig_path) {
        $components = (Get-Content -Raw $vsconfig_path | ConvertFrom-Json).components
        foreach ($component in $components) {
            $arguments += @("-requires", $component)
        }
    }

    return (& $vswhere @arguments)
}

Export-ModuleMember -Function *

Add-VSInstallerDirToPathEnv
