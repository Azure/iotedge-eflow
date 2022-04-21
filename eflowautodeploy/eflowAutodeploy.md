# eflowAutodeploy

eflowAutodeploy enables you to automate the eflow installation, deployment and provisioning easily with a simple json specification.

The script does the following

    * installs the required version of the eflow
    * validate the json parameters
    * creates the required network switch
    * deploys the eflow vm and configures features,proxy, dnsServers
    * provisions the eflow vm with the iotedge provisioning info
    * verifies the eflow vm at the end

## json schema

The below table provides the details of the supported parameters in the json file.

| Parameter | Required | Accepted values | Comments |
| --------- | -------- |---------------- | -------- |
| schemaVersion | Mandatory | 1.0 | Fixed value, schema version. Reserved|
| Version | Mandatory | 1.0 | Fixed value, json instance version. Reserved |
| eflowProduct | Mandatory | **Azure IoT Edge LTS** or **Azure IoT Edge CR X64** or **Azure IoT Edge CR ARM64** | Supported EFLOW product versions |
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
