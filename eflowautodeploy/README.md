# EFLOW Auto Deploy

eflowAutodeploy enables you to automate the Azure IoT Edge for Linux on Windows (EFLOW) installation, deployment and provisioning easily with a simple json specification.

The script does the following:

- Installs the required version of the EFLOW
- Validate the json parameters
- Creates the required network switch
- Deploys the EFLOW virtual machine and configures features,proxy, dnsServers
- Provisions the EFLOW virtual machine with the IoT Edge provisioning info
- Verifies the EFLOW virtual machine is up and running

## Usage

### Autodeploy steps

1. Populate the *eflow-userconfig.json* with the desired parameters and values and place it in the same folder as *eflowAutoDeploy.ps1*.
2. Run the below command to autodeploy using *eflow-userconfig.json*.

```powershell
.\eflowAutoDeploy.ps1 -AutoDeploy
```

### Interactive steps

Alternatively, you can *dot source* the script and invoke functions individually.

1. Populate the *eflow-userconfig.json* with the desired parameters and values.
2. *dot source* the script and call `Start-EflowDeployment` with the json file as input. This will perform the full deployment.

```powershell
. .\eflowAutoDeploy.ps1
Start-EflowDeployment C:\MyConfigs\eflow-userconfig.json
```

### Useful functions

| Function | Remarks |
| --------- | ------ |
|**Config Functions**<ul><li>Get-EFLOWUserConfig</li><li>Set-EFLOWUserConfig -json</li><li>Read-EFLOWUserConfig</li></ul>| UserConfig json functions |
|**Test Functions**<ul><li>Test-EFLOWUserConfig</li><li>Test-EFLOWUserConfigDeploy</li><li>Test-EFLOWUserConfigProvision</li><li>Test-EFLOWUserConfigNetwork</li></ul>| Validates the user configuration for deployment,provisioning. |
|**VM Switch related Functions**<ul><li>New-EFLOWVMSwitch</li><li>Test-EFLOWVMSwitch `-Create` </li><li>Remove-EFLOWVMSwitch</li></ul>| Create EFLOWVMSwitch, Test switch presence with optional `-create` flag and Remove EFLOWVMSwitch. |
|**Deployment functions**<ul><li>Invoke-EFLOWDeploy</li><li>Invoke-EFLOWProvision</li>| Run Deploy and Provision |
|**EFLOW Install related**<ul><li>Get-EFLOWInstalledVersion</li><li>Invoke-EFLOWInstall</li><li>Test-EFLOWInstall `-Install` </li><li>Remove-EFLOWInstall</li></ul>| Install EFLOW, Test EFLOW install with optional `-Install` switch and Remove EFLOW. |
|**Helper functions**<ul><li>Get-HostPCInfo</li><li>Test-AdminRole</li><li>Test-HyperVStatus `-Install` </li>| Get PC info, test admin role and Test Hyper-V install with optional `-Install` switch. |

## JSON schema

The below table provides the details of the supported parameters in the json file. For more information about specific parameters, check [PowerShell functions for Azure IoT Edge for Linux on Windows](https://aka.ms/AzEFLOW-PowerShell).

| Parameter | Required | Type / Values | Comments |
| --------- | -------- |---------------- | -------- |
| schemaVersion | Mandatory | 1.0 | Fixed value, schema version. Reserved|
| Version | Mandatory | 1.0 | Fixed value, json instance version. Reserved |
| eflowProduct | Mandatory | <ul><li>Azure IoT Edge LTS</li><li>Azure IoT Edge CR X64</li><li>Azure IoT Edge CR ARM64</li></ul>| Supported EFLOW product versions |
| `enduser` | |  | End user configuration |
| acceptEula | Mandatory | Yes |  Accept Eula |
| acceptOptionalTelemetry | Optional | Yes | Accept optional telemetry |
| `network` | Optional | | **Network configuration optional for Client SKU**. Mandatory for Server SKU |
| vswitchType | Mandatory | <ul><li>External</li><li>Internal</li></ul> | `Internal`  is supported for Server SKU only |
| vswitchName | Mandatory | String | Switch name to use |
| ip4Address | Optional | IPAddress |  Static IP Address for the EFLOW VM |
| ip4GatewayAddress | Optional | IPAddress | Static Gateway IP Address |
| ip4PrefixLength | Optional | 24 | IP PrefixLength |
| httpProxy | Optional | String | httpProxy link |
| httpsProxy | Optional | String | httpsProxy link |
| dnsServers | Optional | String[] | Array of valid dns servers for VM |
| `vmConfig` | Optional|  | VM configuration |
| cpuCount | Optional |0 | cpuCount|
| memoryInMB | Optional |0| memoryInMB|
| vmDiskSize | Optional |21-2000| Size in GB|
| vmDataSize | Optional | 2-2000| Size in GB, not supported in LTS|
| gpuPassthroughType | Optional |<ul><li>DirectDeviceAssignment</li><li>ParaVirtualization</li></ul>| gpuPassthroughType|
| gpuName | Optional |String| gpuName|
| gpuCount | Optional |0| gpuCount|
| `vmFeature` | Optional|  | Features  |
| DpsTpm| Optional |Boolean| Enable TPM for DPS|
| Defender| Optional |Boolean| Enable Defender feature in VM|
| `eflowProvisioning` | Optional|  | Provisioning configurations  |
| provisioningType| Optional |<ul><li>ManualConnectionString</li><li>ManualX509</li><li>DpsTPM</li><li>DpsX509</li><li>DpsSymmetricKey</li></ul>| Supported provisioning types|
| devConnString| Optional |String| Mandatory for *ManualConnectionString*|
| iotHubHostname| Optional |String| Mandatory for *ManualX509*|
| deviceId| Optional |String| Mandatory for *ManualX509*|
| identityCertPath| Optional |String| Mandatory for *ManualX509*,*DpsX509*|
| identityPrivKeyPath| Optional |String| Mandatory for *ManualX509*,*DpsX509*|
| scopeId| Optional |String| Mandatory for *DpsTPM*,*DpsX509*,*DpsSymmetricKey*|
| symmKey| Optional |String| Mandatory for *DpsSymmetricKey*|
| registrationId| Optional |String| Mandatory for *DpsSymmetricKey*|
| globalEndpoint| Optional |String| DPS endpoint|

```json
{
    "schemaVersion":"1.0",
    "version":"1.0",
    "eflowProduct" : "Azure IoT Edge LTS",
    "enduser":{
        "acceptEula" : "Yes",
        "acceptOptionalTelemetry" : ""
    },
    "network":{
        "adapterName": "Ethernet",
        "vswitchName" : "",
        "vswitchType" : "",
        "ip4Address": "",
        "ip4GatewayAddress": "",
        "ip4PrefixLength" : "",
        "httpProxy":"",
        "httpsProxy":"",
        "dnsServers":""
    },
    "vmConfig":{
        "cpuCount" : 0,
        "memoryInMB" : 0,
        "vmDiskSize" : 0,
        "vmDataSize" : 0,
        "gpuPassthroughType" : "",
        "gpuName" : "",
        "gpuCount" : 0
    },
    "vmFeature":{
        "DpsTpm": false,
        "Defender": false
    },
    "eflowProvisioning":{
        "provisioningType" : "",
        "devConnString" : "",
        "iotHubHostname" : "",
        "deviceId" : "",
        "scopeId" : "",
        "symmKey": "",
        "registrationId" : "",
        "identityCertPath" : "",
        "identityPrivKeyPath" : "",
        "globalEndpoint" : ""
    }
}
```
