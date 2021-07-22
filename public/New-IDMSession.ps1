function New-IDMSession
{
    <#
    .Synopsis
       Creates a persistent IDM authenticated session which can be used by other PSIDM functions
    .DESCRIPTION
       This function creates a persistent, authenticated session in to IDM which can be used by all other
       PSIDM functions instead of explicitly passing parameters.  This removes the need to use the
       -Credential parameter constantly for each function call.
       This is the equivalent of a browser cookie saving login information.
       Session data is stored in this module's PrivateData; it is not necessary to supply it to each
       subsequent function.
    .EXAMPLE
       New-IDMSession -Credential (Get-Credential IDMUsername)
       Get-IDMIssue TEST-01
       Creates a IDM session for IDMUsername.  The following Get-IDMIssue is run using the
       saved session for IDMUsername.
    .INPUTS
       [PSCredential] The credentials to use to create the IDM session
    .OUTPUTS
       [PSIDM.Session] An object representing the IDM session
    #>
    [CmdletBinding()]
    param(
        # Credentials to use for the persistent session
      #  [Parameter(Mandatory = $true,
       #            Position = 0)]
       # [System.Management.Automation.PSCredential] $Credential
    )
    begin
    {
        try
        {
            Write-Debug "[New-IDMSession] Reading IDM server from config file"
            $server = Get-IDMConfigServer -ConfigFile $ConfigFile -ErrorAction Stop
        } catch {
            $err = $_
            Write-Debug "[New-IDMSession] Encountered an error reading configuration data."
            throw $err
        }
        # load DefaultParameters for Invoke-WebRequest
        # as the global PSDefaultParameterValues is not used
        $PSDefaultParameterValues = $global:PSDefaultParameterValues
        $uri = "$server/igi/v2/security/login" 
        $headers = @{
            'Content-Type' = 'application/json';
            'realm' ='Admin';
        }
    }
    process
    {
        try
        { 
            $Credential=Get-IDMAdminAccount
            $result = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get   -Authentication Basic -Credential $Credential  -SkipCertificateCheck
            $datetime=Get-Date  

            Write-Debug "[New-IDMSession] Saving session in module's PrivateData"
            if ($MyInvocation.MyCommand.Module.PrivateData)
            {
                Write-Debug "[New-IDMSession] Adding session result to existing module PrivateData"
                $MyInvocation.MyCommand.Module.PrivateData.Session = $result.content;
                
                Write-Debug "[New-IDMSession] Adding session Last Connection to existing module PrivateData"
                $MyInvocation.MyCommand.Module.PrivateData.SessionLastConnection =$datetime;
            } else {
                Write-Debug "[New-IDMSession] Creating module PrivateData"
                $MyInvocation.MyCommand.Module.PrivateData = @{
                    'Session' = $result.content;
                    'SessionLastConnection'=$datetime;
                }
            }
            Write-Debug "[New-IDMSession] Outputting result"
           # Write-Output $result
           # Write-Output $datetime
        } catch {
            $err = $_
            $webResponse = $err.Exception.Response
            Write-Debug "[New-IDMSession] Encountered an exception from the IDM server: $err"

            Write-Warning "IDM returned HTTP error $($webResponse.StatusCode.value__) - $($webResponse.StatusCode)"

            # Retrieve body of HTTP response - this contains more useful information about exactly why the error
            # occurred
            if($webResponse.StatusCode.value__ -eq "401")
            {
                Set-IDMAdminAccount
                New-IDMSession   
            }
            else {
                $readStream = New-Object -TypeName System.IO.StreamReader -ArgumentList ($webResponse.GetResponseStream())
                $body = $readStream.ReadToEnd()
                $readStream.Close()
                Write-Debug "Retrieved body of HTTP response for more information about the error (`$body)"
                $result = ConvertFrom-Json2 -InputObject $body
                Write-Debug "Converted body from JSON into PSCustomObject (`$result)"
            }
        }
    }
}