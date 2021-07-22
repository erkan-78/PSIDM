function Set-IDMAdminAccount
{
    <#
    .Synopsis
       Obtains user name and password and saves to session parameter
    .DESCRIPTION
       
    .EXAMPLE
      Set-IDMAdminAccount
       Requests user name and password. saves to the session
    .INPUTS
       None
    .OUTPUTS
     
    #>
    [CmdletBinding()]
    param()

    process
    {
        <#if ($MyInvocation.MyCommand.Module.PrivateData.UserName)
        {
            Write-Debug "[Set-IDMAdminAccount] Module private data exists"
           # Return $MyInvocation.MyCommand.Module.PrivateData.UserName
           if($MyInvocation.MyCommand.Module.PrivateData.UserName -eq "")
           {
               $MyInvocation.MyCommand.Module.PrivateData.UserName =$null
              # Set-IDMAdminAccount
           }
            
        } else {#>
            Write-Debug "Get Credential"
         
                $credential=Get-Credential
                $MyInvocation.MyCommand.Module.PrivateData = @{
                    'UserName' = $credential.UserName;
                    'Password' = $credential.Password;
                }
        #}
    }
}