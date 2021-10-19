# EFLOW Util PowerShell functions
Understand EFLOW-Util PowerShell functions that provide extra mechanisms to communicate and interact with the EFLOW VM. 

### :warning: Important
 _The following functions are samples codes that are not meant to be used in production deployments. Furthermore, functions are subject to change and deletion. Make sure you create your own functions base on these samples._.
 
 
 ## EflowUtil-GetEdgeCertificates
 The [**EflowUtil-GetEdgeCertificates**](./EflowUtil-GetEdgeCertificates.ps1) command checks if IoT Edge is configured to use certificates. If so, it will display the path of the certificates. 
 This command takes no parameters. It returns an object that contains three properties:
 - Root CA certificate path
 - Device CA certificate path
 - Private Key path
 
  ## EflowUtil-SetEdgeCertificates
 The [**EflowUtil-SetEdgeCertificates**](./EflowUtil-SetEdgeCertificates.ps1) command sets the IoT Edge certificates in the virtual machine. The command handles copying the certificates into the EFLOW VM, assign the needed permissions, and configure IoT Edge. Use the optional parameters to define a specific file/folder for configuration.
 
| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _rootCAPath_ | Root CA source path on Windows | Root CA it's the topmost certificate authority for the IoT Edge scenario. |
| _deviceCACertificatePath_ | Device CA Certificate path on Windows | - |
| _deviceCAPrivateKeyPath_ | Device CA Private Key path on Windows | - |
| identityCertDirVm |  Certificates folder path on CBL-Mariner (EFLOW VM) | **Optional** |
| _deviceCAPrivateKeyPath_ |  Private Key folder path on CBL-Mariner (EFLOW VM) | **Optional** |


 ## EflowUtil-GetFirewallRules
 The [**EflowUtil-GetFirewallRules**](./EflowUtil-GetFirewallRules.ps1) command checks the CBL-Mariner firewall rules. 
 The command returns the list of all firewall rules configured. Use the optional parameters to define a table or chain.
 
| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _table_ | filter, nat, mangle, raw | Name of table - Each table contains a number of built-in chains and may also contain user-defined chains. |
| _chain_ | INPUT, OUTPUT, FORWARD, DOCKER, DOCKER-ISOLATION-STAGE-1, DOCKER-ISOLATION-STAGE-2, DOCKER-USER | Name of chain - Each chain is a list of rules which can match a set of packets.  |


