try
{
    Import-Module AzureEflow

    $result = Invoke-EflowVmCommand -command 'sudo iptables -L' -ignoreError
    
    if([string]::IsNullOrEmpty($result))
    {
         Write-Host "Fail to get the firewall rules"  -color "Yellow"
    }
    else
    {
        $result
    }
}
catch [Exception]
{
    # An exception was thrown, write it out and exit
    Write-Host "Exception caught!!!"  -color "Red"
    Write-Host $_.Exception.Message.ToString()  -color "Red" 
}
