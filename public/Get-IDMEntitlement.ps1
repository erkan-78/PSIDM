function Get-IDMEntitlement
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
        [string]$EntitlementStartWith,
        [string]$Entitlement,
        [string]$ApplicationName,
         
        [System.Boolean]$IsAdministrative=$false
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
        $uri = "$server/igi/v2/agc/entitlements/.search" 
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
        $body='{
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],'

        if( $IsAdministrative){
            $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:administrative eq 1 and'
        }  else
        {
            $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:administrative eq 0 and' 
        }
        if($FilterString.Length -gt 0)
            {$FilterString=$FilterString.Substring(1, $FilterString.Length -5)
                $body=   $body +'
            "filter" : "' +$FilterString +'",'
            }

            $body=   $body +'
            "startPage": 1,                                                                                                                                                                      
            "count": 1
            
           }
         '
     <#    $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
         $response=$htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length-$htmlresponse.RawContent.IndexOf("{"))
         $response=$response|ConvertFrom-Json 
 
         $ResponseCount=$response.totalResults
 
 #> $ResponseCount=9000
         $body='{
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "startPage": 1,
            "count": ' +$ResponseCount +','
             
            $FilterString=""
            if( $EntitlementStartWith){
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:name sw \"' + $EntitlementStartWith + '\" and'
            }  
            if( $Entitlement){
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:name eq \"' + $Entitlement + '\" and'
            }  
            if( $ApplicationName){
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:application_name eq \"' + $ApplicationName + '\" and'
            }   
            
            if( $IsAdministrative){
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:administrative eq 1 and'
            }  else
            {
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Entitlement:administrative eq 0 and' 
            }
            
            
            if($FilterString.Length -gt 0)
            {$FilterString=$FilterString.Substring(1, $FilterString.Length -5)
                $body=   $body +'
            "filter" : "' +$FilterString +'",'
            }
             $body=   $body + ' 
             "sortOrder": "ascending"
            }
         '   
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
         $response=$htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length-$htmlresponse.RawContent.IndexOf("{"))
         $response=$response|ConvertFrom-Json 
         return $response.resources
         #>
    }

    end
    {
        Write-Debug "[Get-IDMApplication] Complete"
    }
}