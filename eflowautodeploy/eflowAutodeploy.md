# eflowAutodeploy

eflowAutodeploy enables you to automate the eflow installation, deployment and provisioning easily with a simple json specification.

The script does the following

    * installs the required version of the eflow
    * validate the json parameters
    * creates the required network switch
    * deploys the eflow vm and configures features,proxy, dnsServers
    * provisions the eflow vm with the iotedge provisioning info
    * verifies the eflow vm at the end

## Usage

### Autodeploy steps

1. Populate the eflow-userconfig.json with the desired parameters and values and place it in the same folder as eflowAutoDeploy.ps1.
2. Run the below command to autodeploy using eflow-userconfig.json.
```powershell
.\eflowAutoDeploy.ps1 -AutoDeploy
```

### Interactive steps
Alternatively, you can *dot source* the script and invoke functions individually.

1. Populate the eflow-userconfig.json with the desired parameters and values.
2. *dot source* the script and call Start-EflowDeployment with the json file as input. This will perform the full deployment.
```powershell
. .\eflowAutoDeploy.ps1
Start-EflowDeployment c:\myconfigs\eflow-userconfig.json
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



## json schema

The below table provides the details of the supported parameters in the json file.

| Parameter | Required | Accepted values | Comments |
| --------- | -------- |---------------- | -------- |
| schemaVersion | Mandatory | 1.0 | Fixed value, schema version. Reserved|
| Version | Mandatory | 1.0 | Fixed value, json instance version. Reserved |
| eflowProduct | Mandatory | <ul><li>Azure IoT Edge LTS</li><li>Azure IoT Edge CR X64</li><li>Azure IoT Edge CR ARM64</li></ul>| Supported EFLOW product versions |
| enduser | |  | End user configuration |
| acceptEula | Mandatory | Yes |  Accept Eula |
| acceptOptionalTelemetry | Optional | Yes | Accept optional telemetry |

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
