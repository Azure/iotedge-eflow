## Troubleshooting

#### 1. Console message app shows TLS Error ####
This problem is usually caused by a gateway issue. On the IoT Edge device configuration (/etc/iotedge/config.yaml) there's a section called hostname. This automatically gets populated with the system hostname. In some cases, hostname is not found and the user will have to use the EFLOW VM IP. Ensure the gateway name in the C# Windows app matches the hostname in the IoT Edge config.yaml. 

![TLS Error](./Images/TLS_Error.png)

If the previous steps doesn't work, follow these steps:
1. In the config.yaml, change the hostname to the IP address of the EFLOW VM. 
2. `sudo systemctl restart iotedge` 
3. `sudo systemctl status iotedge` - Make sure it says active (running)  
4. `sudo iotedge check` 
5. Run the c# console app using the IP address for the gateway address insted of the hostname
<br/>

#### 2. Error when pushing a module to Azure Contianer Registry ####
To fix an error when pushing the container, ensure that the module.json has the proper registry and container name appended: <repository>.azurecr.io/<containername>. For more information, visit [Can't Push IoT Edge module to Azure Container Registry](https://github.com/MicrosoftDocs/azure-docs/issues/22296).
<br/><br/>

#### 3. Error when pushing a deploying the CSharpModule app ####
To fix this error,  change InteropSampleRegistry value in the registry credentials to direct values or add a separate environment variable for the registry container.
<br/><br/>

#### 4. Operation is not valid due to the current state of the object in microsoft.azure.amqp ####
This is a bug in AMQP and .NET 5. For more information about this error, check this [thread](https://stackoverflow.com/questions/64804036/operation-is-not-valid-due-to-the-current-state-of-the-object-source-microsoft). The solution is adding AMQP version requirement, as well as using .NET Core 3.1LTS  instead of .NET 5
