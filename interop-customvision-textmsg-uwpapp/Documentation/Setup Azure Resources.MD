# Text Messaging & Custom Vision Interop Samples
## Progress

- [x] [Introduction](../README.md)  
- [x] [Step 1 - Setup Development Environment](./Setup%20DevVM.MD)   
- [ ] **Step 2 - Setup Azure Resources**
- [ ] [Step 3 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)  
- [ ] [Step 4 - Develop and publish the IoT Edge Linux module](./Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
- [ ] [Step 5 - Create Certificates for Authentication](./Create%20Certificates%20for%20Authentication.MD)  
- [ ] [Step 6 - Develop the Windows C# UWP Application](./Develop%20the%20Windows%20C%23%20UWP%20Application.MD) 
- [ ] [Step 7 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 8 - Run samples](./Run%20samples.MD) 
- [ ] [Troubleshooting](./Troubleshooting.MD) 
---
Our showcase uses a configuration in the Azure IoT Portal with a sample *IoT Hub*, *IoT Edge Device*, *IoT Downstream Device*, and *IoT Deployment*. This configuration can be set up by executing the following commands in the [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/features). An alternative is using PowerShell with the [Azure PowerShell Module Az](https://docs.microsoft.com/powershell/azure/install-az-ps).

- The *IoT Hub* is the cloud-based hub instance that controls our edge device that runs Azure IoT Edge instance.
- The *IoT Edge Device* represents the virtual device that runs the Azure IoT Edge for Linux instance (on Windows).
- The *IoT Downstream Device* represents our Windows application that communicates with the Linux module.
- The *IoT Deployment* specifies which modules are being deployed onto the IoT Edge Device.

Execute the following instructions:
1. If using the PowerShell Az module, load the Az PowerShell module:

   - The following command is required if the PowerShell execution policy disallows module loading.

       ```
       powershell -ExecutionPolicy Bypass
       ```

   - The following command is required if the module is not imported by default.

      ```
      Import-Module Az
      ```

2. Sign into the Azure Portal with this session only.

    ```
    Connect-AzAccount
    ```

   To persist sign-ins across PowerShell sessions see [Azure PowerShell context objects](https://docs.microsoft.com/powershell/azure/install-az-ps)


3. Use the following command to retrieve a list of subscriptions along with their UUID you are enrolled to.
   ```
   Get-AzSubscription
   ```

4. Use the following command to set a preferred subscription for creating the following steps.
   ```
   Set-AzContext -SubscriptionId "<UUID>"
   ```

*Optional: Create a resource group using [New-AzResourceGroup](https://docs.microsoft.com/azure/iot-hub/iot-hub-create-using-powershell#create-a-resource-group). You might decide to skip this step and use an existing resource group. Ensure to select a suitable subscription under which to create a resource group (make sure you have a subscription that allows you creating resource groups).*

   ```
   New-AzResourceGroup -Name InteropSampleRG -Location "West US"
   ```

   *Use the following command to verify that the resource group has been created under your subscription.*
   ```
   Get-AzResourceGroup
   ```

*Optional: Create an IoT Hub in a specific resource group using [NewAzIoTHub](https://docs.microsoft.com/azure/iot-hub/iot-hub-create-using-powershell#create-an-iot-hub).*

   ```
   New-AzIotHub -ResourceGroupName InteropSampleRG -Name InteropSampleIoTHub -SkuName S1 -Units 1 -Location "West US"
   ```

5. Create an IoT Edge Device, using [Add-AzIoTHubDevice](https://docs.microsoft.com/powershell/module/az.iothub/add-aziothubdevice)

   ```
   Add-AzIoTHubDevice -ResourceGroupName InteropSampleRG -IoTHubName InteropSampleIoTHub -DeviceId InteropSampleEdgeDev -EdgeEnabled
   ```

6. Create an IoT Downstream Device with the IoT Edge Device as parent using [Add-AzIoTHubDevice](https://docs.microsoft.com/powershell/module/az.iothub/add-aziothubdevice)

   ```
   Add-AzIoTHubDevice -ResourceGroupName InteropSampleRG -IoTHubName InteropSampleIoTHub -DeviceId InteropSampleLeafDev -ParentDeviceId InteropSampleEdgeDev
   ```

7. Note down the connection strings for the IoT Edge and leaf devices for use in later steps:

   ```
   Get-AzIotHubDCS -ResourceGroupName InteropSampleRG -IotHubName InteropSampleIoTHub -DeviceId InteropSampleEdgeDev -KeyType primary | fl *
   ```
   ```
   Get-AzIotHubDCS -ResourceGroupName InteropSampleRG -IotHubName InteropSampleIoTHub -DeviceId InteropSampleLeafDev -KeyType primary | fl *
   ```

  > **Note:** It is also possible to get the connection streams using Azure Portal
  >  - Downstream device: in the Azure IoT Hub recently created -> IoT Edge devices -> select the device ID name (InteropSampleDownstreamDev) -> Primary connection string 
  >  - InteropSampleEdgeDev: in the Azure IoT Hub recently created -> IoT Edge Devices -> select the device ID name (InteropSampleEdgeDev) -> Primary connection string 

*Optional: Create a registry for the modules part of this sample using [New-AzContainerRegistry](https://docs.microsoft.com/powershell/module/az.containerregistry/New-AzContainerRegistry) (or other suitable registry):*

   ```
   New-AzContainerRegistry -ResourceGroupName InteropSampleRG -Name InteropSampleRegistry -Sku "Basic" -EnableAdminUser
   ```

Go to [Next Step](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)  
