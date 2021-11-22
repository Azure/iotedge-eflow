# EFLOW Industrial IoT OPC UA scenario using multiple NIC support
## Progress

- [x] [Introduction](../README.md)  
- [x] [Step 1 - Setup OPC UA devices](./Setup%20OPC%20UA%20Devices.MD) 
- [x] [Step 2 - Install Azure IoT Edge for Linux on Windows (EFLOW)](./Install%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)
- [x] [Step 3 - Configure EFLOW Multiple NIC](./Configure%20EFLOW%20Multiple%20NIC.MD)  
- [x] [Step 4 - Provision EFLOW and Configure OPC Publisher](./Provision%20EFLOW%20and%20Configure%20OPC%20Publisher.MD)  
- [ ] **Troubleshooting**
---

#### 1. OPC Publisher doesn't appear to be deployed to the EFLOW VM
This problem is usually caused by a networking issue. Ensure the EFLOW VM has internet connectivity and it's correctly provisioned. 

If the previous steps doesn't work, follow these steps:
1. In the config.yaml, change the hostname to the IP address of the EFLOW VM. 
2. `sudo systemctl restart iotedge` 
3. `sudo systemctl status iotedge` - Make sure it says active (running)  
4. `sudo iotedge check` 

#### 2. Error when connecting to the OPC UA Simulation Server
This problem is usually caused by a networking issue. Ensure the Windows host has connectivity with the device that is running the OPC UA Simulation Server. You can try pinging between the different devices. If ping works, but still no connectivity, make sure there's no firewall blocking the Port 53530.

#### 3. Error when trying to install Azure IoT Edge for Linux on Windows.
Make sure you are meeting all the Azure IoT Edge for Linux on Winodws. For more information, check [AzEFLOW-Requirements](https://aka.ms/AzEFLOW-Requirements).
For any other issue related with installation, check our [EFLOW Wiki](https://aka.ms/AzEFLOW-Wiki) and [EFLOW Issues](https://aka.ms/AzEFLOW-Issues).

#### 4. Error trying to reach internet from EFLOW VM after setting multiple NICs
This problem is usually cause by networking routes inside the EFLOW VM. For more information about network routing, check [EFLOW Network Routing](./../../routing/README.md).
