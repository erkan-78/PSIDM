function Get-IDMUser
{
    <#
    .Synopsis
       Returns information about an User in IDM.
    .DESCRIPTION
       This function obtains references to User in IDM.

    .EXAMPLE
       Get-IDMUser -Username TEST-001
       This example returns a reference to IDM UserName TEST-001.
    .INPUTS
     
    .OUTPUTS
       This function outputs the PSIDM.User object retrieved.
    .NOTES
 
    #>
    [CmdletBinding()]
    param(
        [string]$UID,
        [string]$GivenName,
        [string]$SurName ,
        [string]$UserName
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
        $uri = "$server/igi/v2/agc/users/.search" 
        $Session="Bearer " +$(Get-IDMSession)
 
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
            "schemas": ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "sortBy": "name.familyName",
            "startPage": 1,
            "count": 5,
            "sortOrder": "ascending"
           }
         '
         
         $htmlresponse=Invoke-WebRequest  -uri $uri  -Method post -Headers $headers -SkipCertificateCheck  -Body $htmlbody  
         $htmlresponse=[Text.Encoding]::UTF8.GetString($htmlresponse.Content)
         $response=$htmlresponse|ConvertFrom-Json  
   
         $UserCount=$response.totalResults
         $body='{
            "schemas": ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "sortBy": "name.familyName",
            "startPage": 1,
            "count": ' +$UserCount +','
             
            $FilterString=""
            if( $GivenName){
                    $FilterString=$FilterString+' urn:ietf:params:scim:schemas:core:2.0:User:name.givenName sw  \"' + $GivenName + '\" and'
            }
            if( $SurName){
                $FilterString=$FilterString+' urn:ietf:params:scim:schemas:core:2.0:User:name.familyName sw  \"' + $GiveSurNamenName + '\" and'
            }
            if( $UID){
                $FilterString=$FilterString+' urn:ietf:params:scim:schemas:core:2.0:User:id eq  \"' + $UID + '\" and'
            }

            if( $UserName){
                $FilterString=$FilterString+' urn:ietf:params:scim:schemas:core:2.0:User:userName eq  \"' + $UserName + '\" and'
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