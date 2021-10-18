# EFLOW Routing

When using EFLOW multiple NICs feature, you may want to setup the different routes. By default, EFLOW will create one _Default_ route per _ehtX_ interface assigned to the VM, and associate a random priority.
If all interfaces are connected to internet, random priorities may no be a problem. However if some of the NIC is connected to an _Offline_ network, you may want to prioritize the _Online_ NIC in order to get the EFLOW VM connected to internet. 

The following diagram shows the architecture described:
```
        Secure Network                                      EFLOW VM                                       Internet
      +----------------+
      | Offline Device |  
      +----------------+
             |                                            +--------------+                             +------------------+
             |                                            |     eth0     | .... ( online network) .... |  Online Router   |
             |                                            +--------------+                             +------------------+
+------------------------+                                +--------------+
|     Offline Router     | ..... ( offline network) ..... |     eth1     |
+------------------------+                                +--------------+                                                                                                                                           
```

### Route

EFLOW uses [route](https://man7.org/linux/man-pages/man8/route.8.html) service to manage the network routing alternatives. In order to check the available EFLOW VM routes, use the following steps:

1. Open an elevated PowerShell session
2. Connect to the EFLOW VM using `Connect-EflowVm`
3. Run `sudo route`

![Routing Output](./route-output.png)
