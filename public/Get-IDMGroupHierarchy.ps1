function Get-IDMGroupHierarchy
{
    <#
    .Synopsis
       Returns information about an Group Hierarchy in IDM.
    .DESCRIPTION
       This function obtains references to Group Hierarchy in IDM. 

       search performed by sw (start with) parameter

    .EXAMPLE
       Get-IDMGroupHierarchy -Name TEST-001
       This example returns a reference to IDM Group Hierarchy starts with TEST-001.
    .INPUTS
     
    .OUTPUTS
       This function outputs the PSIDM.Group Hierarchy  object retrieved.
    .NOTES
 
    #>
    [CmdletBinding()]
    param(
        [string]$GroupHierarchyNameStartWith,
        [string]$GroupHierarchyName
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
        $uri = "$server/igi/v2/agc/hierarchies/.search" 
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
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"]
            
           }
         '
         
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
         $response=$htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length-$htmlresponse.RawContent.IndexOf("{"))
         $response=$response|ConvertFrom-Json  
         
         $ResponseCount=$response.totalResults
         $body='{
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "startPage": 1,
            "count": ' +$ResponseCount +','
             
            $FilterString=""
            if( $GroupHierarchyNameStartWith){
                    $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Hierarchy:name sw \"' + $GroupHierarchyNameStartWith + '\" and'
            }  

            
            if( $GroupHierarchyName){
                    $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Hierarchy:name eq \"' + $GroupHierarchyName + '\" and'
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
         $htmlresponse=[Text.Encoding]::UTF8.GetString($htmlresponse.Content)
         $response=$htmlresponse|ConvertFrom-Json  
         return $response.resources
         #>
    }

    end
    {
        Write-Debug "[Get-IDMGroupHierarchy] Complete"
    }
}