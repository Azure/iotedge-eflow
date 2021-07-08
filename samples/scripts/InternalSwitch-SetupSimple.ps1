# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000)
    {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# Check if VM switch already exists
$defaultSwitch = Get-VMSwitch -Name "Default Switch" -SwitchType Internal -ErrorAction SilentlyContinue
if ((($defaultSwitch | Measure-Object).Count -ne 0))
{
    throw "Virtual switch 'Default Switch' already exists"
}

# Create VM switch
New-VMSwitch -Name "Default Switch" -SwitchType Internal
$netAdapter = Get-NetAdapter -Name '*Default Switch*'
if (-Not (($netAdapter | Measure-Object).Count -eq 1)) {
    throw "Only one network adapter for 'Default Switch' expected"
}

# Get IP address octet
$ifIndex = $netAdapter.ifIndex
$maxRetry = 60
$retry = 0
while ($retry -lt $maxRetry)
{
    $ipAddressDesc = Get-NetIPAddress -AddressFamily IPv4  -InterfaceIndex $ifIndex -ErrorAction SilentlyContinue
    if ((($ipAddressDesc | Measure-Object).Count -ne 0))
    {
        break
    }
    Start-Sleep -Seconds 2
    $retry = $retry + 1
}

$descCount = ($ipAddressDesc | Measure-Object).Count
if ($descCount -ne 1) {
    throw "Only one IP address descriptor for interface $ifIndex expected, but got $descCount descriptor"
}

$octets = ($ipAddressDesc.IPAddress -split "\.")
if (-Not ($octets.length -eq 4)) {
    throw "Could not parse IP address octet for IP '$($ipAddressDesc.IPAddress)'"
}

# Set gateway IP address
$octets[3] = "1"
$gatewayIp = ($octets -join ".")
New-NetIPAddress -IPAddress $gatewayIp -PrefixLength 24 -InterfaceIndex $ifIndex

# Create NAT object
$octets[3] = "0"
$natIp = ($octets -join ".")
New-NetNat -Name "Default Switch" -InternalIPInterfaceAddressPrefix "$natIp/24"

# Install DHCP server
Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools

# Add the DHCP default local security groups
netsh dhcp add securitygroups

Restart-Service dhcpserver

# Configure DHCP server
$octets[3] = "100"
$startIp = ($octets -join ".")
$octets[3] = "200"
$endIp = ($octets -join ".")
$subnetMask = "255.255.255.0"
Write-Host "Configure DHCP server scope: startIp='$startIp', endIp='$endIp', subnetMask='$subnetMask'"

Add-DhcpServerV4Scope -Name "AzureIoTEdgeScope" -StartRange $startIp -EndRange $endIp -SubnetMask $subnetMask -State Active

#$octets[3] = "10"
#$dnsIp = ($octets -join ".")
#Set-DhcpServerV4OptionValue -ScopeID $natIp -DnsServer $dnsIp -Router $gatewayIp

Set-DhcpServerV4OptionValue -ScopeID $natIp -Router $gatewayIp
Restart-service dhcpserver
