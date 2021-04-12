
# Text Messaging & Custom Vision Interop Samples

This document uses two samples to demonstrate how Windows applications interoperate with Azure IoT Edge for Linux modules in the EFLOW VM.

1. **Simple Text Messaging**
  Demonstrates minimalistic text message exchange between a Windows application and an Azure IoT Edge for Linux module.

2. **Custom Vision**
   Demonstrates machine learning modules in Azure IoT Edge for Linux in which a Windows application sends camera frames to a Linux module and receives back a description of an item presented to the camera.


**Prerequisites**
- An Azure subscription.
- Basic knowledge of the Azure Cloud portal and its use
- Windows 10 PC with PowerShell to set up an Azure Virtual Machine as your development environment.
- Text Messaging
  - A physical/emulated Windows host device.
- Custom Vision based on [Tutorial: Perform image classification at the edge with Custom Vision Service](https://docs.microsoft.com/azure/iot-edge/tutorial-deploy-custom-vision)
   - A physical Windows host device with a USB Camera connected.
   - Fruits for object classification.

## Instructions
[Step 1 - Setup Development Environment](./Documentation/Setup%20DevVM.MD)   
[Step 2 - Setup Azure Resources](./Documentation/Setup%20Azure%20Resources.MD)  
[Step 3 - Setup Azure IoT Edge for Linux on Windows](./Documentation/Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)  
[Step 4 - Develop and publish the IoT Edge Linux module](./Documentation/Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
[Step 5 - Create Certificates for Authentication](./Documentation/Create%20Certificates%20for%20Authentication.MD)  
[Step 6 - Develop the Windows C# UWP Application](./Documentation//Develop%20the%20Windows%20C%23%20UWP%20Application.MD)  
[Step 7 - Configuring the IoT Edge Device](./Documentation/Configuring%20the%20IoT%20Edge%20Device.MD)  
[Step 8 - Run samples](./Documentation//Run%20samples.MD)  
[Troubleshooting](./Documentation//Troubleshooting.MD)  


## Feedback
If you have problems with this sample, please post an issue in this repository.
