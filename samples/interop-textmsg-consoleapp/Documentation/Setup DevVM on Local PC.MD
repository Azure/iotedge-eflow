# Interop Console App with Linux Edge Module
## Progress

- [x] [Introduction](../README.md)  
- [ ] **Step 1 - Setup Development Environment**
- [ ] [Step 2 - Setup Azure Resources](./Setup%20Azure%20Resources.MD)  
- [ ] [Step 3 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)
- [ ] [Step 4 - Develop and publish the IoT Edge Linux module](./Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
- [ ] [Step 5 - Create Certificates for Authentication](./Create%20Certificates%20for%20Authentication.MD)  
- [ ] [Step 6 - Develop the Windows C# Console Application](./Develop%20the%20Windows%20C%23%20Console%20Application.MD)  
- [ ] [Step 7 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 8 - Deploy the Modules onto the IoT Edge Device](./Deploy%20the%20Modules%20onto%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 9 - Run the Console Application](./Run%20the%20Console%20Application.MD)  
---
Over the course of walk-through for this sample we will be performing various developer tasks including coding, compiling, configuring, and deploying IoT Edge module and IoT devices. To provide a common basis for the performing these tasks, we recommend the use of the [DevVM scripts](https://github.com/Azure-Samples/IoTEdgeAndMlSample/blob/master/DevVM) in the [IoTEdgeandMLSample](https://github.com/Azure-Samples/IoTEdgeAndMlSample) to create an configure an Azure Virtual Machine (VM) specifically for this walk-through.

Where would you like to create your developer environment?  

- [ ] [Virtual Machine in Azure](./Setup%20DevVM%20in%20Azure.MD)  
- [x] Virtual Maching on Local PC
    
---
# Step 1: Setup Local PC   


1. Setup using local machine
    >   **Note:**  The scripts can be run on a machine outside of Azure.  This requires physical hardware or virtual machine that is capable of [nested virtualization](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization)
    >   
1. Alternate: Setup using Azure Cloud Vm  Scripts
    > **Note:** To run these scripts you will need an [Azure Subscription](https://azure.microsoft.com/en-us/free/) in which you have rights to deploy resources
   
    Download the DevVM scripts from the following project to your local machine:   
    https://github.com/Azure-Samples/IoTEdgeAndMlSample/blob/master/DevVM  





1. Log into the Windows environment you wish to configure

1. Open PowerShell as an administrator and navigate to directory containing the scripts

1. Execute the **Set-ExecutionPolicy** cmdlet to allow script execution with the following command:
    ```powershell
    Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
    ```

1. In PowerShell run the scripts in the following order:

     ```powershell
    Enable-HyperV.ps1
    Install-Chocolatey.ps1
    Install-DevMachineSoftware.ps1
    ```

1. Restart the machine with the command 
    ```powershell
    Restart-Computer
    ```

1. Enable Visual Studio Code extensions with the command 
    ```powershell
    .\Enable-CodeExtensions.ps1
    ```

Go to [Next Step](./Setup%20Azure%20Resources.MD)  
