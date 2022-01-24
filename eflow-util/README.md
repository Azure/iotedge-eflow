# EFLOW Util PowerShell functions
Understand EFLOW-Util PowerShell functions that provide extra mechanisms to communicate and interact with the EFLOW VM. 

### :warning: Important
 _The following functions are samples codes that are not meant to be used in production deployments. Furthermore, functions are subject to change and deletion. Make sure you create your own functions based on these samples._.
 
 
 ## Get-EflowVmEdgeCertificates
 The [**Get-EflowVmEdgeCertificates**](./EflowUtil-GetEdgeCertificates.ps1) command checks if IoT Edge is configured to use certificates. If so, it will display the path of the certificates. 
 This command takes no parameters. It returns an object that contains three properties:
 - Root CA certificate path
 - Device CA certificate path
 - Private Key path
 
  ## Set-EflowVmEdgeCertificates
 The [**Set-EflowVmEdgeCertificates**](./EflowUtil-SetEdgeCertificates.ps1) command sets the IoT Edge certificates in the virtual machine. The command handles copying the certificates into the EFLOW VM, assigning the needed permissions, and configuring IoT Edge. Use the optional parameters to define a specific file/folder for configuration.
 
| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _rootCAPath_ | Root CA source path on Windows | Root CA it is the topmost certificate authority for the IoT Edge scenario. |
| _deviceCACertificatePath_ | Device CA Certificate path on Windows | - |
| _deviceCAPrivateKeyPath_ | Device CA Private Key path on Windows | - |
| identityCertDirVm |  Certificates folder path on CBL-Mariner (EFLOW VM) | **Optional** |
| _deviceCAPrivateKeyPath_ |  Private Key folder path on CBL-Mariner (EFLOW VM) | **Optional** |


 ## Get-EflowVmFirewallRules
 The [**Get-EflowVmFirewallRules**](./EflowUtil-GetFirewallRules.ps1) command checks the CBL-Mariner firewall rules. 
 The command returns the list of all firewall rules configured. Use the optional parameters to define a table or chain.
 
 The EFLOW VM uses CBL-Mariner, which includes an iptables based firewall. For more information about iptables, visit [iptables page](https://linux.die.net/man/8/iptables).
 
| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _table_ | filter, nat, mangle, raw | Name of the table - Each table contains several built-in chains and may also contain user-defined chains. |
| _chain_ | INPUT, OUTPUT, FORWARD, DOCKER, DOCKER-ISOLATION-STAGE-1, DOCKER-ISOLATION-STAGE-2, DOCKER-USER | Name of chain - Each chain is a list of rules which can match a set of packets.  |

 ## Set-EflowVmFirewallRules
 The [**Set-EflowVmFirewallRules**](./EflowUtil-GetFirewallRules.ps1) command adds the specified rule to CBL-Mariner firewall. 
 Use the optional parameters to define a custom rule. For a more specific rule, use the _customRule_ parameter.
 
 The EFLOW VM uses CBL-Mariner, which includes an iptables based firewall. For more information about iptables, visit [iptables page](https://linux.die.net/man/8/iptables).
 
| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _table_ | filter, nat, mangle, raw | Name of the table - Each table contains several built-in chains and may also contain user-defined chains. |
| _chain_ | INPUT, OUTPUT, FORWARD, DOCKER, DOCKER-ISOLATION-STAGE-1, DOCKER-ISOLATION-STAGE-2, DOCKER-USER | Name of chain - Each chain is a list of rules which can match a set of packets.  |
| _protocol_ | udp, tcp, icmp, all | Name of network protocol. |
| _port_ | Integer value (0, 65535) | Port number inside CBL-Mariner. |
| _state_ | INVALID, ESTABLISHED, NEW, RELATED, SNAT, DNAT | Network connection states to match. |
| _jump_ | REJECT, ACCEPT, DROP | Network connection states to match. |
| _unset_ | - | If this parameter is present, the provided rule will be unset/deleted. |
| _customRule_ | String |  If a more complex rule is needed, this parameter can be used to input the rule string. |
