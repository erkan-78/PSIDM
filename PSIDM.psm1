$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$Public  = @(Get-ChildItem -Path "$PSScriptRoot\Public\" -include '*.ps1' -recurse -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\" -include '*.ps1' -recurse -ErrorAction SilentlyContinue)

foreach ($ps1 in @($Public + $Private)) {
    try {
        . $ps1.fullname
    } catch {
        Write-Error -Message "Failed to import function $($ps1.fullname): $_"
    }
}

# Apparently, PowerShell only automatically loads format files from modules within PSModulePath.
# This line forces the current PowerShell session to load the module format file, even if the module is saved in an unusual location.
# If this module lives somewhere in your PSModulePath, this line is unnecessary (but it doesn't do any harm either).
$formatFile = Join-Path -Path $moduleRoot -ChildPath 'PSIDM.format.ps1xml'
Write-Verbose "Updating format data with file '$formatFile'"
Update-FormatData -AppendPath $formatFile -ErrorAction Continue

Export-ModuleMember -Function $Public.Basename