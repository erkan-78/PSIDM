function Get-IDMSession
{
    <#
    .Synopsis
       Obtains a reference to the currently saved IDM session
    .DESCRIPTION
       This functio obtains a reference to the currently saved IDM session.  This can provide
       a IDM session ID, as well as the username used to connect to IDM.
    .EXAMPLE
     
       Creates a IDM session for IDM Username, then obtains a reference to it.
    .INPUTS
       None
    .OUTPUTS
       [PSIDM.Session] An object representing the IDM session
    #>
    [CmdletBinding()]
    param()

    process
    {
        if ($MyInvocation.MyCommand.Module.PrivateData)
        {
            Write-Debug "[Get-IDMSession] Module private data exists"
            if ($MyInvocation.MyCommand.Module.PrivateData.Session)
            {
                Write-Debug "[Get-IDMSession] A Session object is saved; outputting"
               # Write-Output $MyInvocation.MyCommand.Module.PrivateData.Session
                $SessionLastConnection=$MyInvocation.MyCommand.Module.PrivateData.SessionLastConnection
                $TimeDifferent=(get-date)-$SessionLastConnection
                if($TimeDifferent.TotalMinutes -gt 4)
                {
                    New-IDMSession

                }
                return $MyInvocation.MyCommand.Module.PrivateData.Session
            } else {
                Write-Debug "[Get-IDMSession] No Session objects are saved"
                Write-Verbose "No IDM sessions have been saved."
                New-IDMSession
                return Get-IDMSession
            }
        } else {
            Write-Debug "[Get-IDMSession] No module private data is defined. No saved sessions exist."
            Write-Verbose "No IDM sessions have been saved."
            New-IDMSession
            return Get-IDMSession
        }
    }
}