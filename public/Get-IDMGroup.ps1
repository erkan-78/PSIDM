function Get-IDMGroup
{
    <#
    .Synopsis
       Returns information about an Group  in IDM.
    .DESCRIPTION
       This function obtains references to Group  in IDM. 

       search performed by sw (start with) parameter
        GroupHierarchyID is mandatory. 1 is refID of default OrganizationUnit hierarchy that comes with default installation
    .EXAMPLE
       Get-IDMGroup -Name TEST-001
       This example returns a reference to IDM Group  starts with TEST-001.
    .INPUTS
     
    .OUTPUTS
       This function outputs the PSIDM.Group   object retrieved.
    .NOTES
 
    #>
    [CmdletBinding()]
    param(
        [string]$NameStartWith,
        [string]$GroupID,
        [string]$GroupIDStartWith,
        [string]$GroupHierarchyID=1
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
        $uri = "$server/igi/v2/agc/hierarchies/"+ $GroupHierarchyID +"/groups/.search" 
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
     <#
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck -ContentType "application/scim+json" -Body $body
         $response=$htmlresponse.RawContent.Substring($htmlresponse.RawContent.IndexOf("{"), $htmlresponse.RawContent.Length-$htmlresponse.RawContent.IndexOf("{"))
         $response=$response|ConvertFrom-Json  
         
         $ResponseCount=$response.totalResults#>
         $ResponseCount=9000
         $body='{
            "schemas" : ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "startPage": 1,
            "count": ' +$ResponseCount +','
             
            $FilterString=""
            if( $NameStartWith){
                    $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Group:name sw \"' + $NameStartWith + '\" and'
            }  
            if( $GroupIDStartWith){
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Group:code sw \"' + $GroupIDStartWith + '\" and'
            }  
            if( $GroupID){
                $FilterString=$FilterString+' urn:ibm:params:scim:schemas:extension:bean:agc:2.0:Group:code eq \"' + $GroupID + '\" and'
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
        Write-Debug "[Get-IDMGroup] Complete"
    }
}