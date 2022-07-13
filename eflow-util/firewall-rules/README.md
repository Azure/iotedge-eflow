# EFLOW Util Firewall Rules functions

Understand EFLOW-Util FirewallRules PowerShell functions that provide extra mechanisms to get and set firewall rules of EFLOW VM.

### :warning: Important
_The following functions are samples codes that are not meant to be used in production deployments. Furthermore, functions are subject to change and deletion. Make sure you create your own functions based on these samples._.

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
