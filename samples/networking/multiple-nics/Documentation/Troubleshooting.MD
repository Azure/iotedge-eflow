# EFLOW Industrial IoT OPC UA scenario using multiple NIC support
## Progress

- [x] [Introduction](../README.md)  
- [x] [Step 1 - Setup OPC UA devices](./Setup%20OPC%20UA%20Devices.MD) 
- [x] [Step 2 - Install Azure IoT Edge for Linux on Windows (EFLOW)](./Install%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)
- [x] [Step 3 - Configure EFLOW Multiple NIC](./Configure%20EFLOW%20Multiple%20NIC.MD)  
- [x] [Step 4 - Provision EFLOW and Configure OPC Publisher](./Provision%20EFLOW%20and%20Configure%20OPC%20Publisher.MD)  
- [ ] **Troubleshooting**
---

#### 1. OPC Publisher doesn't appear to be deployed to the EFLOW VM####
This problem is usually caused by a networking issue. Ensure the EFLOW VM has internet connectivity and it's correctly provisioned. 

If the previous steps doesn't work, follow these steps:
1. In the config.yaml, change the hostname to the IP address of the EFLOW VM. 
2. `sudo systemctl restart iotedge` 
3. `sudo systemctl status iotedge` - Make sure it says active (running)  
4. `sudo iotedge check` 

#### 2. Error when pushing a module to Azure Contianer Registry ####
To fix an error when pushing the container, ensure that the module.json has the proper registry and container name appended: <repository>.azurecr.io/<containername>. For more information, visit [Can't Push IoT Edge module to Azure Container Registry](https://github.com/MicrosoftDocs/azure-docs/issues/22296).
<br/><br/>

#### 3. Error when pushing a deploying the CSharpModule app ####
To fix this error,  change InteropSampleRegistry value in the registry credentials to direct values or add a separate environment variable for the registry container.
<br/><br/>

#### 4. Operation is not valid due to the current state of the object in microsoft.azure.amqp ####
This is a bug in AMQP and .NET 5. For more information about this error, check this [thread](https://stackoverflow.com/questions/64804036/operation-is-not-valid-due-to-the-current-state-of-the-object-source-microsoft). The solution is adding AMQP version requirement, as well as using .NET Core 3.1LTS  instead of .NET 5
```csharp
<PackageReference Include="Microsoft.Azure.Amqp" Version="2.4.13" /> 
```
<br/>