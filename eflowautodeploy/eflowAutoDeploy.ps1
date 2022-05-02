<#
    .DESCRIPTION
        This module contains the functions related to EFLOW setup on a PC
#>
param(
    [switch] $AutoDeploy
)

$eflowAutoDeployVersion = "1.0.220502.1700"
$isServerSKU = $false
$EFLOWUserConfigFile = $null
$EFLOWUserConfig = $null
$eflowProducts = @{
    "Azure IoT Edge LTS"      = "https://aka.ms/AzEflowMSI"
    "Azure IoT Edge CR X64"   = "https://aka.ms/AzEFLOWMSI-CR-X64"
    "Azure IoT Edge CR ARM64" = "https://aka.ms/AzEFLOWMSI-CR-ARM64"
}
$eflowProvisioningProperties = @{
    "ManualConnectionString" = @("devConnString")
    "ManualX509"             = @("iotHubHostname", "deviceId", "identityCertPath", "identityPrivKeyPath")
    "DpsTPM"                 = @("scopeId")
    "DpsX509"                = @("scopeId", "identityCertPath", "identityPrivKeyPath")
    "DpsSymmetricKey"        = @("scopeId", "symmKey", "registrationId")
}

function Test-AdminRole {
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
                [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Error: This module requires Administrator mode!" -ForegroundColor Red
        return $false
    }
    return $true
}
function Get-HostPCInfo {
    Write-Host "Running eflowAutoDeploy version $eflowAutoDeployVersion"
    $pOS = Get-CimInstance Win32_OperatingSystem
    Write-Host "HostOS Info : $($pOS.Caption)($($pOS.OperatingSystemSKU)) - $($pOS.Version) - $($pOS.MUILanguages) - $($pOS.CSName)"
    #ProductTypeDomainController -Value 2 , #ProductTypeServer -Value 3
    $script:isServerSKU = ($pOS.ProductType -eq 2 -or $pOS.ProductType -eq 3)
}
function Get-EFLOWUserConfig {
    if ($null -eq $Script:EFLOWUserConfig){
        Write-Host "Error: EFLOW UserConfig is not set." -ForegroundColor Red
    }
    return $Script:EFLOWUserConfig
}
function Read-EFLOWUserConfig {
    if ($EFLOWUserConfigFile) {
        $Script:EFLOWUserConfig = Get-Content "$EFLOWUserConfigFile" | ConvertFrom-Json
    }
    else { Write-Host "Error: EFLOWUserConfigFile not configured" -ForegroundColor Red }
}
function Set-EFLOWUserConfig {
    <#
    .DESCRIPTION
        Check if there is a configuration file, and loads the JSON configuration
        into a variable
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$eflowjson
    )

    if (!(Test-Path -Path "$eflowjson" -PathType Leaf)) {
        Write-Host "Incorrect json file: $eflowjson"
        return
    }
    Write-Host "Loading $eflowjson.."
    $Script:EFLOWUserConfigFile = "$eflowjson"
    Read-EFLOWUserConfig
}
function Test-EFLOWUserConfigNetwork {
    <#
    .DESCRIPTION
        Checks the EFLOW user configuration needed for EFLOW Network setup
    #>
    $errCnt = 0
    $eflowConfig = Get-EFLOWUserConfig
    # 0) Check Hyper-V status
    Test-HyperVStatus | Out-Null
    # 1) Check the virtual switch name
    $nwCfg = $eflowConfig.network
    if ($null -eq $nwCfg) {
        if ($script:isServerSKU) {
            Write-Host "Error: Server SKU, requires Network configuration, see https://aka.ms/AzEFLOW-vSwitch" -ForegroundColor Red
            return $false
        }
        else {
            Write-Host "* Client SKU : No Network configuration specified. Default Switch will be used." -ForegroundColor Green
            return $true
        }
    }

    if ([string]::IsNullOrEmpty($nwCfg.vswitchName)) {
        if ($script:isServerSKU) {
            Write-Host "Error: Server SKU, a virutal switch is needed - For more information about EFLOW virutal switch creation, see https://aka.ms/AzEFLOW-vSwitch" -ForegroundColor Red
            $errCnt += 1
        }
        else { Write-Host "* Client SKU : No virtual switch specified - Default Switch will be used." -ForegroundColor Green }
    }
    else { Write-Host "* Using virtual switch $($nwCfg.vswitchName)" -ForegroundColor Green }
    # Check if the virtual switch type and associated properties
    switch ($nwCfg.vSwitchType) {
        "Internal" {
            if (-not $script:isServerSKU ) {
                Write-Host "Error: vSwitchType is incorrect. Supported types : External (Client and Server) and Internal (Server)" -ForegroundColor Red
                $errCnt += 1
            }
            else { Write-Host "* Using vSwitchType Internal" -ForegroundColor Green }
        }
        "External" {
            if ([string]::IsNullOrEmpty($nwCfg.adapterName)) {
                Write-Host "Error: adapterName required for External switch" -ForegroundColor Red
                $errCnt += 1
            }
            else {
                $nwadapters = (Get-NetAdapter -Physical) | Where-Object { $_.Status -eq "Up" }
                if ($nwadapters.Name -notcontains ($nwCfg.adapterName)) {
                    Write-Host "Error: $($nwCfg.adapterName) not found. External switch creation will fail." -ForegroundColor Red
                    $errCnt += 1
                }
                else { Write-Host "* Using vSwitchType External" -ForegroundColor Green }
            }
        }
        default {
            if ($script:isServerSKU ) {
                Write-Host "Error: vSwitchType is incorrect. Supported types : External (Client and Server) and Internal (Server)" -ForegroundColor Red
                $errCnt += 1
            }
            else { Write-Host "* Using vSwitchType Default" -ForegroundColor Green }
        }
    }

    # 3) Check the virtual switch IP address allocation
    Write-Host "--- Verifying virtual switch IP address allocation..."
    if ([string]::IsNullOrEmpty($nwCfg.ip4Address) -and
        [string]::IsNullOrEmpty($nwCfg.ip4GatewayAddress) -and
        [string]::IsNullOrEmpty($nwCfg.ip4PrefixLength)) {
        Write-Host "* No static IP address provided - DHCP allocation or auto-static ip(internal switch) will be used" -ForegroundColor Green
    } elseif ([string]::IsNullOrEmpty($nwCfg.ip4Address) -or
              [string]::IsNullOrEmpty($nwCfg.ip4GatewayAddress) -or
              [string]::IsNullOrEmpty($nwCfg.ip4PrefixLength)) {
                Write-Host "Error: IP4Address, IP4GatewayAddress and IP4PrefixLength parameters are needed" -ForegroundColor Red
                $errCnt += 1
    } else {
        $ipconfigstatus = $true
        if (-not ($nwCfg.ip4Address -as [IPAddress] -as [Bool])) {
            Write-Host "Error: Invalid IP4Address $($nwCfg.ip4Address)" -ForegroundColor Red
            $errCnt += 1
            $ipconfigstatus = $false
        }
        else {
            #Ping IP to ensure it is free
            $status = Test-Connection $nwCfg.ip4Address -Count 1 -Quiet
            if ($status) {
                Write-Host "Error: ip4Address $($nwCfg.ip4Address) in use" -ForegroundColor Red
                $errCnt += 1
                $ipconfigstatus = $false
            }
        }

        if (-not ($nwCfg.ip4GatewayAddress -as [IPAddress] -as [Bool])) {
            Write-Host "Error: Invalid IP4GatewayAddress $($nwCfg.ip4GatewayAddress)" -ForegroundColor Red
            $errCnt += 1
            $ipconfigstatus = $false
        }
        else {
            $status = Test-Connection $nwCfg.ip4GatewayAddress -Count 1 -Quiet
            if (($status) -and ($nwCfg.vSwitchType -ieq "Internal")) {
                # flagging it as a warning for now. To be fixed.
                Write-Host "Warning: ip4GatewayAddress $($nwCfg.ip4GatewayAddress) may be in use already" -ForegroundColor Yellow
                #$errCnt += 1
                #$ipconfigstatus = $false
            }
            if ((-not $status) -and ($nwCfg.vSwitchType -ieq "External")) {
                Write-Host "Error: ip4GatewayAddress $($nwCfg.ip4GatewayAddress) is not reachable. Required for external switch" -ForegroundColor Red
                $errCnt += 1
                $ipconfigstatus = $false
            }
        }

        [IPAddress]$mask="255.255.255.0"
        if ( (([IPAddress]$nwCfg.ip4GatewayAddress).Address -band $mask.Address ) -ne (([IPAddress]$nwCfg.ip4Address).Address -band $mask.Address))
        {
            Write-Host "Error: ip4GatewayAddress and ip4Address are not in the same subnet" -ForegroundColor Red
            $errCnt += 1
            $ipconfigstatus = $false
        }
        if ($nwCfg.ip4PrefixLength -as [int] -lt 0 -and $nwCfg.ip4PrefixLength -as [int] -ge 32) {
            Write-Host "Error: Invalid IP4PrefixLength $($nwCfg.ip4PrefixLength). Should be an integer between 0 and 32" -ForegroundColor Red
            $errCnt += 1
            $ipconfigstatus = $false
        }
        if ($ipconfigstatus) {
            Write-Host "* Using virtual switch with IP4Address: $($nwCfg.ip4Address)" -ForegroundColor Green
            Write-Host "                     ip4GatewayAddress: $($nwCfg.ip4GatewayAddress)" -ForegroundColor Green
            Write-Host "                          PrefixLength: $($nwCfg.ip4PrefixLength)" -ForegroundColor Green
        }
    }
    #TODO : Ping dnsServers for reachability. No Tests for http proxies
    $retval = $true
    if ($errCnt) {
        Write-Host "$errCnt errors found in the Network Configuration. Fix errors before deployment" -ForegroundColor Red
        $retval = $false
    }
    else {
        Write-Host "*** No errors found in the Network Configuration." -ForegroundColor Green
    }
    return $retval
}

function Test-EFLOWUserConfigInstall {
    $errCnt = 0
    $eflowConfig = Get-EFLOWUserConfig
    Write-Host "`n--- Verifying EFLOW Install Configuration..."
    # 0) Check if EFLOW is already installed
    $version = Get-EFLOWInstalledVersion

    # 1) Check the product requested is valid
    if ($Script:eflowProducts.ContainsKey($eflowConfig.eflowProduct)) {
        Write-Host "* $($eflowConfig.eflowProduct)" -ForegroundColor Green
        if ($version) { #if already installed, check if they match
            $product = $version.Split(",")
            if ($product[0] -ne $eflowConfig.eflowProduct) {
                Write-Host "Error: Installed product does not match requested product." -ForegroundColor Red
                $errCnt += 1
            }
        }
    }
    else {
        Write-Host "Error: Incorrect eflowProduct." -ForegroundColor Red
        Write-Host "Supported products: [$($Script:eflowProducts.Keys -join ',' )]"
        $errCnt += 1
    }
    # 2) Check if ProductUrl is valid if specified
    if (-not [string]::IsNullOrEmpty($eflowConfig.eflowProductUrl) -and
    (-not ([system.uri]::IsWellFormedUriString($eflowConfig.eflowProductUrl,[System.UriKind]::Absolute)))) {
        Write-Host "Error: eflowProductUrl is incorrect. $($eflowConfig.eflowProductUrl)." -ForegroundColor Red
        $errCnt += 1
    }
    # 3) Check if the install options are proper
    $installOptions = $eflowConfig.installOptions
    if ($installOptions) {
        $installOptItems = @("installPath","vhdxPath")
        foreach ($item in $installOptItems) {
            $path = $installOptions[$item]
            if (-not [string]::IsNullOrEmpty($path) -and
            (-not (Test-Path -Path $path -IsValid))) {
                Write-Host "Error: Incorrect item. : $path" -ForegroundColor Red
                $errCnt += 1
            }
        }
    }
    $retval = $true
    if ($errCnt) {
        Write-Host "$errCnt errors found in the Install Configuration. Fix errors before Install" -ForegroundColor Red
        $retval = $false
    }
    else {
        Write-Host "*** No errors found in the Install Configuration." -ForegroundColor Green
    }
    return $retval
}
function Test-EFLOWUserConfigDeploy {
    <#
    .DESCRIPTION
        Checks the EFLOW user configuration needed for EFLOW VM deployment
        Return $true if no blocking errors are found, and $false otherwise
    #>
    $errCnt = 0
    $eflowConfig = Get-EFLOWUserConfig
    $euCfg = $eflowConfig.enduser
    Write-Host "`n--- Verifying EFLOW VM Deployment Configuration..."
    # 1) Check Mandatory configuration EULA
    Write-Host "--- Verifying EULA and telemetry..."
    if (($euCfg.acceptEula) -and ($euCfg.acceptEula -eq "Yes")) {
        Write-Host "* EULA accepted." -ForegroundColor Green
    }
    else {
        Write-Host "Error: Missing/incorrect mandatory EULA acceptance. Set acceptEula Yes" -ForegroundColor Red
        $errCnt += 1
    }

    if (($euCfg.acceptOptionalTelemetry) -and ($euCfg.acceptOptionalTelemetry -eq "Yes")) {
        Write-Host "* Optional telemetry accepted." -ForegroundColor Green
    }
    else {
        Write-Host "- Optional telemetry not accepted. Basic telemetry will be sent." -ForegroundColor Yellow
    }

    # 2) Check the virtual switch specified
    Write-Host "--- Verifying virtual switch..."
    if (-not (Test-EFLOWVMSwitch)) {
        $errCnt += 1
    }

    # 3) Check the virtual switch memory, cpu, and storage
    $vmCfg = $eflowConfig.vmConfig
    Write-Host "--- Verifying virtual machine resources..."

    if ($vmCfg.cpuCount -gt 0) {
        Write-Host "* Virtual machine will be created with $($vmCfg.cpuCount) vCPUs."
    }
    else {
        Write-Host "* No custom vCPUs used - Using default configuration, virtual machine will be created with 1 vCPUs."
    }

    if ($vmCfg.memoryInMB -gt 0) {
        Write-Host "* Virtual machine will be created with $($vmCfg.memoryInMB) MB of memory."
    }
    else {
        Write-Host "* No custom memory used - Using default configuration, virtual machine will be created with 1024 MB of memory."
    }

    if ($vmCfg.vmDiskSize) {
        if (($vmCfg.vmDiskSize -ge 21)  -and ($vmCfg.vmDiskSize -le 2000)) { #Between 21 GB and 2 TB
            Write-Host "* Virtual machine VHDX will be created with $($vmCfg.vmDiskSize) GB disk size."
        } else {
            Write-Host "Error: vmDiskSize should be between 21 GB and 2000 GB(2TB)" -ForegroundColor Red
            $errCnt += 1
        }
    }
    else {
        Write-Host "* No custom disk size used - Using default configuration, virtual machine VHDX will be created with 29 GB of disk size."
    }
    if ($vmCfg.vmDataSize) {
        if (($vmCfg.vmDataSize -ge 2)  -and ($vmCfg.vmDataSize -le 2000)) { #Between 2 GB and 2 TB
            Write-Host "* Virtual machine VHDX will be created with $($vmCfg.vmDataSize) GB of data size."
        } else {
            Write-Host "Error: vmDataSize should be between 2 GB and 2000 GB(2TB)" -ForegroundColor Red
            $errCnt += 1
        }
    }
    else {
        Write-Host "* No custom data size used - Using default configuration, virtual machine VHDX will be created with 10 GB of data size."
    }
    if (($eflowConfig.eflowProduct -ieq "Azure IoT Edge LTS") -and ($vmCfg.vmDataSize -gt 0)) {
        Write-Host "Error: vmDataSize is not supported in Azure IoT Edge LTS" -ForegroundColor Red
        $errCnt += 1
    }
    if ($vmCfg.vmDiskSize -and $vmCfg.vmDiskSize) {
        Write-Host "Error: Both vmDataSize and vmDiskSize specified. Specify one." -ForegroundColor Red
        $errCnt += 1
    }
    # 4) Check GPU passthrough configuration
    Write-Host "--- Verifying GPU passthrough configuration..."
    if ([string]::IsNullOrEmpty($vmCfg.gpuPassthroughType)) {
        Write-Host "* No GPU passthrough being used - CPU only allocation"
    }
    else {
        if ($vmCfg.gpuPassthroughType -ne 'DirectDeviceAssignment' -and $vmCfg.gpuPassthroughType -ne 'ParaVirtualization') {
            Write-Host "Error: GpuPassthrough type is invalid - Supported types: DirectDeviceAssignment or ParaVirtualization" -ForegroundColor Red
            $errCnt += 1
        }
        else { Write-Host "* $($vmCfg.gpuPassthroughType) specified" -ForegroundColor Green }

        if ([string]::IsNullOrEmpty($vmCfg.gpuName)) {
            Write-Host "Error: GpuName must be provided" -ForegroundColor Red
            $errCnt += 1
        }
    }
    $retval = $true
    if ($errCnt) {
        Write-Host "$errCnt errors found in the Deployment Configuration. Fix errors before deployment" -ForegroundColor Red
        $retval = $false
    }
    else {
        Write-Host "*** No errors found in the Deployment Configuration." -ForegroundColor Green
    }
    return $retval
}
function Test-EFLOWUserConfigProvision {
    <#
    .DESCRIPTION
        Checks the EFLOW user configuration needed for EFLOW provisioning
    #>
    $errCnt = 0
    $eflowConfig = Get-EFLOWUserConfig
    $provCfg = $eflowConfig.eflowProvisioning
    if ($null -eq $provCfg) {
        Write-Host "- Provisioning Configuration not specified." -ForegroundColor Yellow
        return $false
    }
    Write-Host "`n--- Verifying EFLOW VM Provisioning Configuration..."
    # 1) Check provisioning type
    Write-Host "--- Verifying provisioning type..."

    if (-not $Script:eflowProvisioningProperties.ContainsKey($provCfg.provisioningType)) {
        Write-Host "Error: provisioningType is incorrect or not specified.`nSupported provisioningType: [$($Script:eflowProvisioningProperties.Keys)]" -ForegroundColor Red
        $errCnt += 1
    }
    else {
        Write-Host "* $($provCfg.provisioningType)" -ForegroundColor Green
    }

    # 2) Check parameters required for the provisioning type
    Write-Host "--- Verifying provisioning parameters.."
    $reqSettings = $Script:eflowProvisioningProperties[$provCfg.provisioningType]
    if ($reqSettings) {
        #if we have valid parameter array
        foreach ($setting in $reqSettings) {
            #verify if the parameters are specified
            $value = ($provCfg.PSObject.Properties | Where-Object { $_.Name -ieq $setting }).Value
            if ($value) {
                # Not writing out the value as it may have credentials that we dont want in logs
                Write-Host "* $setting Ok" -ForegroundColor Green
                #if parameter contains path, ensure that the file is present
                if ($setting.Contains("Path")) {
                    if (-not (Test-Path -Path $value -PathType Leaf)) {
                        Write-Host "Error: File not found :$value" -ForegroundColor Red
                        $errCnt += 1
                    }
                }
            }
            else {
                Write-Host "Error: provisioningType $($provCfg.provisioningType) requires $setting value." -ForegroundColor Red
                $errCnt += 1
            }
        }
    }

    $retval = $true
    if ($errCnt) {
        Write-Host "$errCnt errors found in the Provisioning Configuration. Fix errors before deployment" -ForegroundColor Red
        $retval = $false
    }
    else {
        Write-Host "No errors found in the Provisioning Configuration." -ForegroundColor Green
    }
    return $retval
}
function Test-EFLOWUserConfig {

    $installResult = Test-EFLOWUserConfigInstall
    $deployResult = Test-EFLOWUserConfigDeploy
    $provResult = Test-EFLOWUserConfigProvision

    return ($installResult -and $deployResult -and $provResult)

}
function Test-EFLOWInstall {
    Param
    (
        [Switch] $Install
    )

    $eflowVersion = Get-EFLOWInstalledVersion

    if ($null -eq $eflowVersion) {
        if (!$Install) { return $false }
        if (-not (Invoke-EFLOWInstall)){ return $false }
    }
    $mod = Get-Module -Name AzureEFLOW
    #check if module is loaded
    if (!$mod) {
        Write-Host "Importing AzureEFLOW.."
        Import-Module -Name AzureEFLOW -Force
    }
    $version = (Get-Module -Name AzureEFLOW).Version.ToString()
    Write-Host "AzureEFLOW Module:$version"
    return $true
}
function Test-HyperVStatus {
    Param
    (
        [Switch] $Enable
    )
    #Enable HyperV
    $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
    if ($feature.State -ne "Enabled") {
        Write-Host "Hyper-V is disabled" -ForegroundColor Red
        if ($Enable) {
            Write-Host "Enabling Hyper-V"
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
            if ($script:isServerSKU) {
                Install-WindowsFeature -Name RSAT-Hyper-V-Tools -IncludeAllSubFeature
            }
            Write-Host "Reboot machine for enabling Hyper-V" -ForegroundColor Yellow
        }
        return $false
    }
    else {
        Write-Host "Hyper-V is enabled" -ForegroundColor Green
    }
    return $true
}
function Invoke-EFLOWInstall {
    <#
    .DESCRIPTION
        Checks if EFLOW MSI is installed, and installs it if not
    #>
    #TODO : Add Force flag to uninstall and install req product
    $version = Get-EFLOWInstalledVersion
    if ($version) {
        Write-Host "$version is already installed"
        return $true
    }
    $eflowConfig = Get-EFLOWUserConfig
    if ($null -eq $eflowConfig) { return $retval }
    if (-not (Test-EFLOWUserConfigInstall)) { return $false } # bail if the validation failed
    $reqProduct = $eflowConfig.eflowProduct
    $url = $Script:eflowProducts[$reqProduct]
    if ($eflowConfig.eflowProductUrl) {
        $url = $eflowConfig.eflowProductUrl
    }
    Write-Host "Installing $reqProduct from $url"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest $url -OutFile .\AzureIoTEdge.msi
    $argList = '/I AzureIoTEdge.msi /qn '
    if ($eflowConfig.installOptions){
        $installPath = $eflowConfig.installOptions.installPath
        if ($installPath) {
            $argList = $argList + "INSTALLDIR=""$($installPath)"" "
        }
        $vhdxPath = $eflowConfig.installOptions.vhdxPath
        if ($vhdxPath) {
            $argList = $argList + "VHDXDIR=""$($vhdxPath)"" "
        }
    }
    Write-Host $argList
    Start-Process msiexec.exe -Wait -ArgumentList $argList
    Remove-Item .\AzureIoTEdge.msi
    $ProgressPreference = 'Continue'
    Write-Host "$reqProduct successfully installed"
    return $true
}
function Remove-EFLOWInstall {
    <#
   .DESCRIPTION
       Checks if EFLOW MSI is installed, and removes it if installed
   #>
    $eflowInfo = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty |  Where-Object { $_.DisplayName -match 'Azure IoT Edge *' }
    if ($null -eq $eflowInfo) {
        Write-Host "Azure IoT Edge is not installed."
    }
    else {
        Write-Host "$($eflowInfo.DisplayName) version $($eflowInfo.DisplayVersion) is installed. Removing..."
        Start-Process msiexec.exe -Wait -ArgumentList "/x $($eflowInfo.PSChildName) /quiet /noreboot"
        # Remove the module from Powershell session as well
        if (Get-Module -Name AzureEFLOW) {
            Remove-Module -Name AzureEFLOW -Force
        }
        Write-Host "$($eflowInfo.DisplayName) successfully removed."
    }
}
function Get-EFLOWInstalledVersion {
    <#
   .DESCRIPTION
       Gets EFLOW version if installed
   #>
    $eflowInfo = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty |  Where-Object { $_.DisplayName -match 'Azure IoT Edge *' }
    $retval = $null
    if ($null -eq $eflowInfo) {
        Write-Host "Azure IoT Edge is not installed."
    }
    else {
        $retval = "$($eflowInfo.DisplayName),$($eflowInfo.DisplayVersion)"
        Write-Host "$retval is installed."
    }
    return $retval
}
function Invoke-EFLOWDeploy {
    <#
    .DESCRIPTION
        Loads the configuration and tries to deploy the EFLOW VM
    #>
    $retval = Test-EFLOWUserConfigDeploy
    if (-not $retval) { return $false }
    $eflowDeployParams = @{}
    $eflowConfig = Get-EFLOWUserConfig
    #Properties are validated. So just add here
    $eflowDeployParams.Add("acceptEula", "Yes")
    if ($eflowConfig.enduser.acceptOptionalTelemetry -eq "Yes") {
        $eflowDeployParams.Add("acceptOptionalTelemetry", "Yes")
    }

    if ($eflowConfig.network){ #network params are optional for Client using default switch
        foreach ($property in $($eflowConfig.network).PSObject.Properties) {
            $reqProperties = @("vswitchName", "vswitchType", "ip4Address", "ip4GatewayAddress","ip4PrefixLength")
            if ($reqProperties -contains $property.Name) {
                if (($property.Value.GetType().Name -eq "String" -and -not [string]::IsNullOrEmpty($property.Value)) -or
                    ($property.Value.GetType().Name -eq "Int32" -and $property.Value -gt 0)) {
                    $eflowDeployParams.Add($property.Name, $property.Value)
                }
            }
        }
    }
    if ($eflowConfig.vmConfig) { #vmConfig params are optional
        foreach ($property in $($eflowConfig.vmConfig).PSObject.Properties) {
            if (($property.Value.GetType().Name -eq "String" -and -not [string]::IsNullOrEmpty($property.Value)) -or
                ($property.Value.GetType().Name -eq "Int32" -and $property.Value -gt 0)) {
                $eflowDeployParams.Add($property.Name, $property.Value)
            }
        }
    }

    Write-Verbose "EFLOW VM deployment parameters..."
    Write-Verbose ($eflowDeployParams | Out-String)

    #TODO - Check if eflow is deployed previously before attempting to deploy again.
    Write-Host "Starting EFLOW VM deployment..."
    $retval = Deploy-Eflow @eflowDeployParams

    if ($retval -ieq "OK") {
        Write-Host "* EFLOW VM deployment successfull." -ForegroundColor Green
    } else {
        Write-Host "Error: EFLOW VM deployment failed with the below error message." -ForegroundColor Red
        Write-Host "Error message : $retval." -ForegroundColor Red
        return $false
    }

    #Set-EflowVmDnsServers
    if ($eflowConfig.network.dnsServers) {
        Write-Host "Setting DNS Servers to $($eflowConfig.network.dnsServers)"
        Set-EflowVmDNSServers -dnsServers $eflowConfig.network.dnsServers
    }
    # If using Static IP and no DnsServer is provided, use main interface DNS servers
    elseif ($eflowConfig.network.vswitchType -eq "Internal") {
        # Get DNS servers including gateway
        Write-Host "Looking for available DNS Servers..."
        [String[]] $dnsservers = $(((Get-NetIPConfiguration | Foreach-Object IPv4DefaultGateway).NextHop))
        $dnsservers += $(Get-DnsClientServerAddress | Where-Object { $_.AddressFamily -eq 2 } | ForEach-Object { $_.ServerAddresses })
        $dnsservers = $dnsservers | Where-Object { -Not [string]::IsNullOrEmpty($_) } | Select-Object -uniq
        Write-Host "Setting DNS Servers to $dnsservers"
        Set-EflowVmDNSServers -dnsServers $dnsservers
    }

    if ($eflowConfig.network.httpsProxy) {
        Write-Host "Setting HTTPS Proxy to $($eflowConfig.network.httpsProxy)"
        Invoke-EflowVmCommand "echo 'https_proxy=$($eflowConfig.network.httpsProxy)' | sudo tee -a /etc/environment"
        Invoke-EflowVmCommand "source /etc/environment"
    }

    if ($eflowConfig.network.httpProxy) {
        Write-Host "Setting HTTP Proxy to $($eflowConfig.network.httpProxy)"
        Invoke-EflowVmCommand "echo 'http_proxy=$($eflowConfig.network.httpProxy)' | sudo tee -a /etc/environment"
        Invoke-EflowVmCommand "source /etc/environment"
    }

    #Set-EflowVmFeature
    if ($eflowConfig.vmFeature.DpsTpm) {
        Write-Host "Enabling vmFeature: DpsTpm"
        Set-EflowVmFeature -feature DpsTpm -enable
    }
    if ($eflowConfig.vmFeature.Defender) {
        Write-Host "Enabling vmFeature: Defender"
        Set-EflowVmFeature -feature Defender -enable
    }
    return $true
}
function Invoke-EFLOWProvision {
    <#
    .DESCRIPTION
        Loads the configuration and tries to provision the EFLOW VM
    #>
    $retval = Test-EFLOWUserConfigProvision
    if (-not $retval) { return $false }
    $eflowConfig = Get-EFLOWUserConfig
    $provCfg = $eflowConfig.eflowProvisioning
    $eflowProvisionParams = @{
        "provisioningType" = $provCfg.provisioningType
    }
    $reqSettings = $Script:eflowProvisioningProperties[$provCfg.provisioningType]
    if ($reqSettings) {
        #if we have valid parameter array
        foreach ($setting in $reqSettings) {
            #get values for each required setting. No validation here as its done earlier
            $value = ($provCfg.PSObject.Properties | Where-Object { $_.Name -ieq $setting }).Value
            $eflowProvisionParams.Add($setting, $value)
        }
    }
    if ($provCfg.globalEndpoint) {
        $eflowProvisionParams.Add("globalEndpoint", $provCfg.globalEndpoint)
    }

    Write-Verbose "--- EFLOW VM provisioning parameters..."
    #Making this Verbose as we possibly show secure key/connection string in logs
    Write-Verbose ($eflowProvisionParams | Out-String)

    Write-Host "Starting EFLOW VM provisioning..."
    $retval = Provision-EflowVm @eflowProvisionParams
    if ($retval -ieq "OK") {
        Write-Host "* EFLOW provisioning successfull." -ForegroundColor Green
    } else {
        Write-Host "Error: EFLOW provisioning failed with the below error message." -ForegroundColor Red
        Write-Host "Error message : $retval." -ForegroundColor Red
        return $false
    }
    return $true
}
function Test-EFLOWVMSwitch {
    Param
    (
        [Switch] $Create
    )
    $usrCfg = Get-EFLOWUserConfig
    $nwCfg = $usrCfg.network
    if (! (Test-EFLOWUserConfigNetwork)) { return $false }

    if ([string]::IsNullOrEmpty($nwCfg.vSwitchName)) {
        if (-not $script:isServerSKU) {
            Write-Host "vSwitchName not specified. Checking Default switch."
            $defaultSwitch = Get-VMSwitch -Name 'Default Switch' -ErrorAction SilentlyContinue
            if ($defaultSwitch) {
                Write-Host "* Default switch found" -ForegroundColor Green
                $retval = $true
            } else {
                Write-Host "Error: Default switch not found" - -ForegroundColor Red
                $retval = $false
            }
            return $retval
        }
        Write-Host "Error: vSwitchName not specified. " -ForegroundColor Red
        return $false
    }
    # we have a name to check further..
    $eflowSwitch = Get-VMSwitch -Name $nwCfg.vSwitchName -ErrorAction SilentlyContinue

    if ($eflowSwitch) {
        #Switch is found. If it is internal, grab the IP details to pass
        if ($nwCfg.vSwitchType -ieq "Internal") {
            # check if nat is present as well
            $nat = Get-NetNat -Name "$($nwCfg.vSwitchName)-NAT"
            if ($nat) {
                # Nat already exists, grab the ip info
                $eflowSwitchAdapter = Get-NetAdapter | Where-Object { $_.Name -eq "vEthernet ($($nwCfg.vSwitchName))" }
                $ifIndex = $eflowSwitchAdapter.ifIndex
                $switchIpAddress = (Get-NetIPAddress -AddressFamily IPv4  -InterfaceIndex $ifIndex).IPAddress
                $ipPrefix = ($switchIpAddress.Split('.')[0..2]) -join '.'
                Write-Host "* Internal Switch found with the ipPrefix $ipPrefix"
                if ($null -eq $nwCfg.ip4Address) {
                    # No ip address specified. So update those fields with the generated ones.
                    $nwCfg | Add-Member -MemberType NoteProperty -Name ip4GatewayAddress -Value $switchIpAddress
                    $nwCfg | Add-Member -MemberType NoteProperty -Name ip4Address -Value "$ipPrefix.2"
                    $nwCfg | Add-Member -MemberType NoteProperty -Name ip4PrefixLength -Value 24
                    Write-Host "Using EFLOW static IP4Address: $($nwCfg.ip4Address)" -ForegroundColor Green
                    Write-Host "           Gateway IP4Address: $($nwCfg.ip4GatewayAddress)" -ForegroundColor Green
                    Write-Host "                 PrefixLength: $($nwCfg.ip4PrefixLength)" -ForegroundColor Green
                }
            }
            else {
                # No Nat. Not in a good state, so either we auto delete and recreate or report error and bail
                # bailing out for now
                Write-Host "Error: Internal switch found. NAT not found. Delete switch and recreate." -ForegroundColor Red
                return $false
            }
        }
        Write-Host "* Name:$($eflowSwitch.Name) - Type:$($eflowSwitch.SwitchType)" -ForegroundColor Green
    }
    else {
        # no switch found. Create if requested
        if ($Create) {
            return New-EFLOWVMSwitch
        }
        Write-Host "Error: VMSwitch $($nwCfg.vSwitchName) not found." -ForegroundColor Red
        return $false
    }
    return $true
}
function New-EFLOWVMSwitch {
    $usrCfg = Get-EFLOWUserConfig
    $nwCfg = $usrCfg.network

    $eflowSwitch = Get-VMSwitch -Name $nwCfg.vSwitchName -ErrorAction SilentlyContinue

    if ($eflowSwitch) {
        Write-Host "Error: Name:$($eflowSwitch.Name) - Type:$($eflowSwitch.SwitchType) already exists" -ForegroundColor Red
        return $false
    }
    # no switch found. Create if requested
    Write-Host "Creating VMSwitch $($nwCfg.vSwitchName) - $($nwCfg.vSwitchType)..."
    if ($nwCfg.vSwitchType -ieq "Internal") {
        $eflowSwitch = New-VMSwitch -SwitchType $nwCfg.vSwitchType -Name $nwCfg.vSwitchName -ErrorAction SilentlyContinue
        # give some time for the switch creation to succeed
        Start-Sleep 10
        $eflowSwitchAdapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "vEthernet ($($nwCfg.vSwitchName))" }
        if ($null -eq $eflowSwitchAdapter) {
            Write-Host "Error: [vEthernet ($($nwCfg.vSwitchName))] is not found. $($nwCfg.vSwitchName) switch creation failed.  Please try switch creation again."
            return $false
        }

        if ($null -eq $nwCfg.ip4Address) {
            # No ip address specified. So update those fields with the generated ones.
            $ifIndex = $eflowSwitchAdapter.ifIndex
            $switchIpAddress = (Get-NetIPAddress -AddressFamily IPv4  -InterfaceIndex $ifIndex -ErrorAction SilentlyContinue).IPAddress
            if (!$switchIpAddress) {
                Write-Host "Error: [vEthernet ($($nwCfg.vSwitchName))] IP address not found. IP assignment of the virtual switch $($nwCfg.vSwitchName) failed.  Please try switch creation again."
                return $false
            }
            $ipPrefix = ($switchIpAddress.Split('.')[0..2]) -join '.'
            $nwCfg | Add-Member -MemberType NoteProperty -Name ip4GatewayAddress -Value "$ipPrefix.1"
            $nwCfg | Add-Member -MemberType NoteProperty -Name ip4Address -Value "$ipPrefix.2"
            $nwCfg | Add-Member -MemberType NoteProperty -Name ip4PrefixLength -Value 24
        }

        $ipPrefix = ($nwCfg.ip4GatewayAddress.Split('.')[0..2]) -join '.'
        $natPrefix = "$ipPrefix.0/$($nwCfg.ip4PrefixLength)"

        New-NetIPAddress -IPAddress $nwCfg.ip4GatewayAddress -PrefixLength $nwCfg.ip4PrefixLength -InterfaceAlias "vEthernet ($($nwCfg.vSwitchName))" | Out-Null
        Write-Host "Using EFLOW static IP4Address: $($nwCfg.ip4Address)" -ForegroundColor Green
        Write-Host "           Gateway IP4Address: $($nwCfg.ip4GatewayAddress)" -ForegroundColor Green
        Write-Host "                 PrefixLength: $($nwCfg.ip4PrefixLength)" -ForegroundColor Green

        New-NetNat -Name "$($nwCfg.vSwitchName)-NAT" -InternalIPInterfaceAddressPrefix $natPrefix |  Out-Null
    }
    else {
        $nwadapters = (Get-NetAdapter -Physical -ErrorAction SilentlyContinue) | Where-Object { $_.Status -eq "Up" }
        if ($nwadapters.Name -notcontains ($nwCfg.adapterName)) {
            Write-Host "Error: $($nwCfg.adapterName) not found. External switch not created." -ForegroundColor Red
            return $false
        }
        $eflowSwitch = New-VMSwitch -NetAdapterName $nwCfg.adapterName -Name $nwCfg.vSwitchName -ErrorAction SilentlyContinue
        # give some time for the switch creation to succeed
        Start-Sleep 10
        $eflowSwitchAdapter = Get-NetAdapter | Where-Object { $_.Name -eq "vEthernet ($($nwCfg.vSwitchName))" }
        if ($null -eq $eflowSwitchAdapter) {
            Write-Host "Error: [vEthernet ($($nwCfg.vSwitchName))] is not found. $($nwCfg.vSwitchName) switch creation failed.  Please try switch creation again."
            return $false
        }
    }
    return $true
}

function Remove-EFLOWVMSwitch {
    $usrCfg = Get-EFLOWUserConfig
    $switchName = $($usrCfg.network.vswitchName)
    $eflowSwitch = Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue
    if ($eflowSwitch) {
        Write-Host "Removing $switchName"
        Remove-VMSwitch -Name $switchName
        if ($eflowSwitch.SwitchType -ieq "Internal") {
            $eflowNat = Get-NetNat -Name "$switchName-NAT"
            if ($eflowNat) {
                Write-Host "Removing $switchName-NAT"
                Remove-NetNAt -Name "$switchName-NAT"
            }
        }
    }
}

# Main function for full functional path
function Start-EflowDeployment {
    Param
    (
        [String]$eflowjson
    )
    # Get Host Information first
    Get-HostPCInfo
    # Validate input parameter. Use default json in the same path if not specified
    if ([string]::IsNullOrEmpty($eflowjson)) {
        $eflowjson = "$PSScriptRoot\eflow-userconfig.json"
    }

    if (!(Test-Path -Path "$eflowjson" -PathType Leaf)) {
        Write-Host "Error: $eflowjson not found" -ForegroundColor Red
        return
    }
    $eflowjson = (Resolve-Path -Path $eflowjson).Path
    Set-EFLOWUserConfig $eflowjson # validate later after creating the switch
    # Check admin role
    if (!(Test-AdminRole)) { return }
    # Check PC prequisites (Hyper-V, EFLOW and CLI)
    if (!(Test-HyperVStatus)) { return } # TODO Enable Hyper-V, register task to resume after reboot

    if (!(Test-EFLOWInstall -Install)) { return }

    if (!(Test-EFLOWVMSwitch -Create)) { return } #create switch if specified

    # We are here.. all is good so far. Validate and deploy eflow
    if (!(Invoke-EFLOWDeploy)) {
        #deployment failed. We should atleast remove the switch and NAT we created. Other installs are harmless.
        Remove-EFLOWVMSwitch
        return
    }

    if (!(Invoke-EFLOWProvision)) { return }
    if (Verify-EflowVm) {
        Write-Host "** EFLOW VM deployment successful." -ForegroundColor Green
    }
}

### MAIN ###
# If autodeploy switch is specified, start eflow deployment with the default json file path (.\eflow-userconfig.json)
if ($AutoDeploy) {
    Start-EflowDeployment
} else {
    Get-HostPCInfo
    $eflowjson = "$PSScriptRoot\eflow-userconfig.json"
    if (Test-Path -Path "$eflowjson" -PathType Leaf) {
        Set-EFLOWUserConfig $eflowjson
    }
}
