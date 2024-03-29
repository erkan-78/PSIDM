function Set-IDMConfigServer
{
    <#
    .Synopsis
       Defines the configured URL for the IDM server
    .DESCRIPTION
       This function defines the configured URL for the IDM server that PS for IDM should manipulate. By default, this is stored in a config.xml file at the module's root path.
    .EXAMPLE
       Set-IDMConfigServer 'https://IDM.DOMAINNAME.com:9343/'
       This example defines the server URL of the IDM server configured in the PS for IDM config file.
    .EXAMPLE
       Set-IDMConfigServer 'https://IDM.DOMAINNAME.com:9343/' -ConfigFile C:\idmconfig.xml
       This example defines the server URL of the IDM server configured at C:\idmconfig.xml.
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       [System.String]
    .NOTES
       Support for multiple configuration files is limited at this point in time, but enhancements are planned for a future update.
    #>
    [CmdletBinding()]
    param(
        # The base URL of the IDM instance.
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Uri')]
        [String] $Server,

        [String] $ConfigFile
    )

    # Using a default value for this parameter wouldn't handle all cases. We want to make sure
    # that the user can pass a $null value to the ConfigFile parameter...but if it's null, we
    # want to default to the script variable just as we would if the parameter was not
    # provided at all.

    if (-not ($ConfigFile))
    {
#        Write-Debug "[Set-IDMConfigServer] ConfigFile was not provided, or provided with a null value"
        # This file should be in $moduleRoot/Functions/Internal, so PSScriptRoot will be $moduleRoot/Functions
        $moduleFolder = Split-Path -Path $PSScriptRoot -Parent
#        Write-Debug "[Set-IDMConfigServer] Module folder: $moduleFolder"
        $ConfigFile = Join-Path -Path $moduleFolder -ChildPath 'config.xml'
#        Write-Debug "[Set-IDMConfigServer] Using default config file at [$ConfigFile]"
    }

    if (-not (Test-Path -Path $ConfigFile))
    {
#        Write-Debug "[Set-IDMConfigServer] Creating config file '$ConfigFile'"
        $xml = [XML] '<Config></Config>'

    } else {
#        Write-Debug "[Set-IDMConfigServer] Loading config file '$ConfigFile'"
        $xml = New-Object -TypeName XML
        $xml.Load($ConfigFile)
    }

    $xmlConfig = $xml.DocumentElement
    if ($xmlConfig.LocalName -ne 'Config')
    {
        throw "Unexpected document element [$($xmlConfig.LocalName)] in configuration file. You may need to delete the config file and recreate it using this function."
    }

    # Check for trailing slash and strip it if necessary
    $fixedServer = $Server.Trim()

    if ($fixedServer.EndsWith('/') -or $fixedServer.EndsWith('\')) {
        $fixedServer = $Server.Substring(0, $Server.Length - 1)
    }

    if ($xmlConfig.Server)
    {
#        Write-Debug "[Set-IDMConfigServer] Changing the existing Server element to the provided value '$Server'"
        $xmlConfig.Server = $fixedServer
    } else {
#        Write-Debug "[Set-IDMConfigServer] Creating new element Server"
        $xmlServer = $xml.CreateElement('Server')
#        Write-Debug "[Set-IDMConfigServer] Writing InnerText property with provided value '$Server'"
        $xmlServer.InnerText = $fixedServer
#        Write-Debug "[Set-IDMConfigServer] Adding element to existing XML file"
        [void] $xmlConfig.AppendChild($xmlServer)
    }

#    Write-Debug "[Set-IDMConfigServer] Saving XML file"
    try
    {
        $xml.Save($ConfigFile)
    } catch {
        $err = $_
#        Write-Debug "[Set-IDMConfigServer] Encountered an error saving the XML file"
#        Write-Debug "[Set-IDMConfigServer] Throwing exception"
        throw $err
    }
#    Write-Debug "[Set-IDMConfigServer] Complete"

}