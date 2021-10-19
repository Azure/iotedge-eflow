 <#
.DESCRIPTION
    Iptables is used to set up, maintain, and inspect the tables of IP packet filter rules in the Linux kernel.

.PARAMETER table
    Name of table - Each table contains a number of built-in chains and may also contain user-defined chains.

.PARAMETER chain
    Name of chain - Each chain is a list of rules which can match a set of packets. 

#>

param (

    [ValidateSet("INPUT", "OUTPUT", "FORWARD", "DOCKER", "DOCKER-ISOLATION-STAGE-1", "DOCKER-ISOLATION-STAGE-2", "DOCKER-USER")]
    [String] $chain,

    [ValidateSet("filter", "nat", "mangle", "raw")]
    [String] $table
)


try
{
    Import-Module AzureEflow

    [String]$vmCommand = "sudo iptables -L "

    if (![string]::IsNullOrEmpty($table))
    {
        $vmCommand += " --table $($table)"  
    }

     if (![string]::IsNullOrEmpty($chain))
    {
        $vmCommand += " $($chain)"  
    }


    $result = Invoke-EflowVmCommand -command $vmCommand -ignoreError
    
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
