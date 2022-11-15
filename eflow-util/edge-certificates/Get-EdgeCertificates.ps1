function Get-EflowVmEdgeCertificates
{
    try
    {
        # Check IoT Edge version (1.1 or 1.2)
        $iotEdgeVersion = Invoke-EflowVmCommand "sudo iotedge version"
        
        if([string]::IsNullOrEmpty($iotEdgeVersion))
        {
            Write-Host "Could not retrieve IoT Edge version"  -ForegroundColor "Red"
            return
        }
    
        # By default, command is for IoT Edge 1.1 using config.yaml file
        $vmCommand = 'sudo cat /etc/iotedge/config.yaml  | grep "[[:blank:]]*certificates:" -A4'
    
        # If IoT Edge = 1.2/1.3/1.4 check for config.toml file
        if($iotEdgeVersion -Match "1.2" -Or $iotEdgeVersion -Match "1.3" -Or $iotEdgeVersion -Match "1.4")
        {
            $vmCommand = 'sudo cat /etc/aziot/config.toml | grep "[[:blank:]]*certificates:" -A4'
        }
    
        $result = Invoke-EflowVmCommand -command $vmCommand -ignoreError
        
        if([string]::IsNullOrEmpty($result))
        {
            return [PSCustomObject]@{
                device_ca_cert = "-"
                device_ca_pk = "-"
                trusted_ca_certs = "-"
            }
        }
        else
        {
            return [PSCustomObject]@{
                device_ca_cert = $result[1].Split(":")[1]
                device_ca_pk = $result[2].Split(":")[1]
                trusted_ca_certs = $result[2].Split(":")[1]
            }
        }
    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Host "Exception caught!!!"  -ForegroundColor "Red"
        Write-Host $_.Exception.Message.ToString()  -ForegroundColor "Red" 
    }
}

