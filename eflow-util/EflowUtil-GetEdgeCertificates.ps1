
try
{
    Import-Module AzureEflow

    $result = Invoke-EflowVmCommand -command 'sudo cat /etc/iotedge/config.yaml  | grep "^certificates:" -A4' -ignoreError
    
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
    Write-Host "Exception caught!!!"  -color "Red"
    Write-Host $_.Exception.Message.ToString()  -color "Red" 
}

