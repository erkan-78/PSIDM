function Add-IDMEntitlementToGroup
{
    <#
    .Synopsis
       Returns information about an Application in IDM.
    .DESCRIPTION
       This function obtains references to Application in IDM. 

       search performed by sw (start with) parameter

    .EXAMPLE
       Get-IDMApplication -Name TEST-001
       This example returns a reference to IDM Application starts with TEST-001.
    .INPUTS
     
    .OUTPUTS
       This function outputs the PSIDM.Application  object retrieved.
    .NOTES
        The service has  a hard count limitation of 140 unless you provide any search criteria.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$EntitlementId,
        [Parameter(Mandatory=$true)] [string]$GroupID,
        [System.Boolean]$IsHierarchial=$false,
        [System.Boolean]$IsDefault=$false,
        [System.Boolean]$IsvisibilityViolation=$false,
        [System.Boolean]$IsEnabled=$True
    )

    begin
    {

        try
        {
            Write-Debug "[New-IDMApplication] Reading IDM server from config file"
            $server = Get-IDMConfigServer -ConfigFile $ConfigFile -ErrorAction Stop
        } catch {
            $err = $_
            Write-Debug "[New-IDMApplication] Encountered an error reading configuration data."
            throw $err
        }
        # load DefaultParameters for Invoke-WebRequest
        # as the global PSDefaultParameterValues is not used
        $PSDefaultParameterValues = $global:PSDefaultParameterValues
        $uri = "$server/igi/v2/agc/groups/$GroupID/entitlement/?entId=$EntitlementId"
        $Session="Bearer " +$(Get-IDMSession)
 
        $headers = @{
            'Content-Type' = 'application/json';
            'realm' ='Ideas';
            'Authorization'= $Session;
            'Accept-Language'='*';
            'Accept-Encoding'='utf-8';
            'Accept-Charset'='utf-8'; 
        }
        
    }
    process
    { 
        if($IsHierarchial)
        {
            $uri = $uri +"&hierarchy=true"
        }
        else {
            $uri = $uri +"&hierarchy=false"
        }
        if($IsDefault)
        {
            $uri = $uri +"&default=true"
        }
        else {
            $uri = $uri +"&default=false"
        }
        if($IsvisibilityViolation)
        {
            $uri = $uri +"&visibilityViolation=true"
        } 
        else {
            $uri = $uri +"&visibilityViolation=false"
        }
        if($IsEnabled)
        {
            $uri = $uri +"&enabled=true"
        }  
        else {
            $uri = $uri +"&enabled=false"
        } 
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json"  
 
         write-host $htmlresponse
         
         return $htmlresponse
         #>
    }

    end
    {
        Write-Debug "[Get-IDMApplication] Complete"
    }
}