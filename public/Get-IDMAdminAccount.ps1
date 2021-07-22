
function Get-IDMAdminAccount
{
    <#
    .Synopsis
       Obtains a reference to the currently saved IDM session
    .DESCRIPTION
       This functio obtains a reference to the currently saved Set-IDMAdminAccount session.   
    .EXAMPLE
        
       Get-IDMSession
       Creates a IDM session for IDM user, then obtains a reference to it.
    .INPUTS
       None
    .OUTPUTS
       Session An object representing the IDM session
    #>
    [CmdletBinding()]
    param()

    process
    {
        if ($MyInvocation.MyCommand.Module.PrivateData.UserName)
        {
            $Credential= New-Object System.Management.Automation.PSCredential ($MyInvocation.MyCommand.Module.PrivateData.UserName, $MyInvocation.MyCommand.Module.PrivateData.Password)
            Return $Credential
        } else {
            Write-Debug "No module Username in private data is defined. No saved sessions exist."
            Set-IDMAdminAccount
            Get-IDMAdminAccount
        }
    }
}