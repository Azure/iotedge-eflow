 <#
.DESCRIPTION
    Iptables is used to set up, maintain, and inspect the tables of IP packet filter rules in the Linux kernel. For more information, check https://linux.die.net/man/8/iptables

.PARAMETER table
    Name of table - Each table contains a number of built-in chains and may also contain user-defined chains.

.PARAMETER chain
    Name of chain - Each chain is a list of rules which can match a set of packets. 

.PARAMETER protocol
    Name of network protocol (UDP/TCP/ICMP).

.PARAMETER port
    Port number inside CBL-Mariner

.PARAMETER state
    Network connection states to match

.PARAMETER jump
    This specifies the target of the rule; i.e., what to do if the packet matches it.

.PARAMETER customRule
    If a more complex rule is needed, this parameter cna be used to input the rule string

#>

param (

    [Parameter(Mandatory)]
    [ValidateSet("INPUT", "OUTPUT", "FORWARD", "DOCKER", "DOCKER-ISOLATION-STAGE-1", "DOCKER-ISOLATION-STAGE-2", "DOCKER-USER")]
    [String] $chain,

    [ValidateSet("filter", "nat", "mangle", "raw")]
    [String] $table,

    [ValidateSet("udp", "tcp", "icmp", "all")]
    [Parameter(Mandatory)]
    [String] $protocol,

    [ValidateRange(0,65535)]
    [Parameter(Mandatory)]
    [int] $port,

    [ValidateSet("INVALID", "ESTABLISHED", "NEW", "RELATED", "SNAT", "DNAT")]
    [String] $state,

    [ValidateSet("REJECT", "ACCEPT", "DROP")]
    [Parameter(Mandatory)]
    [String] $jump,

    [String] $customRule
)


try
{
    Import-Module AzureEflow
    [String]$vmCommand = "";

    if (![string]::IsNullOrEmpty($customRule))
    {
        $vmCommand = $customRule       
    }
    else
    {
         $vmCommand = "sudo iptables -A "

        if (![string]::IsNullOrEmpty($chain))
        {
            $vmCommand += " $($chain)"  
        }

        if (![string]::IsNullOrEmpty($protocol))
        {
            $vmCommand += " -p $($protocol)"  
        }
        
        if ($port -ge 1)
        {
            $vmCommand += " --dport $($port)"  
        }

        if (![string]::IsNullOrEmpty($table))
        {
            $vmCommand += " --table $($table)"  
        }

        if (![string]::IsNullOrEmpty($jump))
        {
            $vmCommand += " -j $($jump)"  
        }

        if (![string]::IsNullOrEmpty($state))
        {
            $vmCommand += " --state $($state)"  
        }
    }

    $result = Invoke-EflowVmCommand -command $vmCommand -ignoreError
    
    if([string]::IsNullOrEmpty($result))
    {
         Write-Host "Rule added"
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
