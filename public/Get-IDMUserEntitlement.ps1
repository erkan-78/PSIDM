function Get-IDMUserEntitlement
{
    <#
    .Synopsis
       Returns information about an User in IDM.
    .DESCRIPTION
       This function obtains references to User in IDM.

    .EXAMPLE
       Get-Get-IDMUserEntitlement -UID 1 -EntitlementName

       This example returns a reference to IDM UID 1.
    .INPUTS
     
    .OUTPUTS
       This function outputs the PSIDM.User object retrieved.
    .NOTES
 
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$UID,
        [string]$EntitlementName
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

        if(!($UID))
        {
            $err = $_
            Write-Debug "[New-IDMSession] UID is required"
            throw $err
            
        }

        # load DefaultParameters for Invoke-WebRequest
        # as the global PSDefaultParameterValues is not used
        $PSDefaultParameterValues = $global:PSDefaultParameterValues
        $uri = "$server/igi/v2/agc/users/1176/entitlement/.search" 
        $Session="Bearer " +$(Get-IDMSession)
        Write-Host $uri 
        $headers = @{
            'Content-Type' = 'application/scim+json';
            'realm' ='Ideas';
            'Authorization'= $Session;
            'Accept-Language'='*';
            
        }
        
    }
    process
    {
        $htmlbody='{
            "schemas": ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"]
           }
         '
         
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck  -Body $htmlbody  
         $htmlresponse=[Text.Encoding]::UTF8.GetString($htmlresponse.Content)
        # $response=$htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length-$htmlresponse.RawContent.IndexOf("{"))
        # $response=
         $response=$htmlresponse|ConvertFrom-Json  
   
         $EntitlementCount=$response.totalResults
         $body='{
            "schemas": ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "count": ' +$EntitlementCount +','
             
            $FilterString=""
            if( $EntitlementName){
                    $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:name co  \"' + $EntitlementName + '\" and'
            } 
            if($FilterString.Length -gt 0)
            {$FilterString=$FilterString.Substring(1, $FilterString.Length -5)
                $body=   $body +'
            "filter" : "' +$FilterString +'",'
            }
           # ,
             $body=   $body + '
            "sortOrder": "ascending"
           }
         ' 
      
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
         $htmlresponse=[Text.Encoding]::UTF8.GetString($htmlresponse.Content)
         # $response=$htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length-$htmlresponse.RawContent.IndexOf("{"))
         # $response=
          $response=$htmlresponse|ConvertFrom-Json  
         return $response.resources
    }

    end
    {
        Write-Debug "[Get-IDMIssue] Complete"
    }
}