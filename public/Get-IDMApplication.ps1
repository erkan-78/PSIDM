function Get-IDMApplication {
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
 
    #>
    [CmdletBinding()]
    param(
        [string]$ApplicationNameStartWith,
        [string]$ApplicationName
    )

    begin {

        try {
            Write-Debug "[New-IDMApplication] Reading IDM server from config file"
            $server = Get-IDMConfigServer -ConfigFile $ConfigFile -ErrorAction Stop
        }
        catch {
            $err = $_
            Write-Debug "[New-IDMApplication] Encountered an error reading configuration data."
            throw $err
        }
        # load DefaultParameters for Invoke-WebRequest
        # as the global PSDefaultParameterValues is not used
        $PSDefaultParameterValues = $global:PSDefaultParameterValues
        $uri = "$server/igi/v2/agc/applications/.search" 
        $Session = "Bearer " + $(Get-IDMSession)
 
        $headers = @{
            'Content-Type'    = 'application/json';
            'realm'           = 'Ideas';
            'Authorization'   = $Session;
            'Accept-Language' = '*';
            'Accept-Encoding' = 'utf-8';
            'Accept-Charset'  = 'utf-8'; 
        }
        
    }
    process {
        $body = '{
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"]
            
           }
         '

        $htmlresponse = Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
        $response = $htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length - $htmlresponse.RawContent.IndexOf("{"))
        $response = $response | ConvertFrom-Json  
        $FilterString = ""

        $ResponseCount = $response.totalResults 
        $body = '{
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "startPage": 1,
            "count": ' + $ResponseCount + ',' 
        if ( $ApplicationNameStartWith) {
            $FilterString = $FilterString + ' urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Application:name sw \"' + $ApplicationNameStartWith + '\" and'
        }  
        if ( $ApplicationName) {
            $FilterString = $FilterString + ' urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Application:name eq \"' + $ApplicationName + '\" and'
        }  
        if ($FilterString.Length -gt 0) {

        
            $FilterString = '"filter" : "' + $FilterString.Substring(1, $FilterString.Length - 5) + '",'
        
        }
        $body = $body + $FilterString + ' 
             "sortOrder": "ascending"
            }
         '
      
       
        $htmlresponse = Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
        $response = $htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length - $htmlresponse.RawContent.IndexOf("{"))
        $response = $response | ConvertFrom-Json 
        $result=$response.resources
        return $result
    }

    end {
        Write-Debug "[Get-IDMApplication] Complete"
    }
}