# Text Messaging & Custom Vision Interop Samples
## Progress

- [x] [Introduction](../README.md)  
- [ ] **Step 1 - Setup Development Environment**
- [ ] [Step 2 - Setup Azure Resources](./Setup%20Azure%20Resources.MD)
- [ ] [Step 3 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)
- [ ] [Step 4 - Develop and publish the IoT Edge Linux module](./Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
- [ ] [Step 5 - Create Certificates for Authentication](./Create%20Certificates%20for%20Authentication.MD)  
- [ ] [Step 6 - Develop the Windows C# UWP Application](./Develop%20the%20Windows%20C%23%20UWP%20Application.MD)  
- [ ] [Step 7 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 8 - Run samples](./Run%20samples.MD) 
---

In this tutorial, we describe how to build the Windows application and the Linux modules, how to upload the latter to our Azure Registry, and how to add our sample deployment to our sample IoT Edge Device. These steps are executed in a separate Windows development environment, which is an Azure cloud VM we set up with the following steps.

  > **Note:** The development environment can also be set up manually on a separate physical Windows development machine.

On a Windows device with PowerShell installed, follow these steps to create the Windows development cloud VM serving as build environment.

1. Complete the following steps from [Tutorial: Set up an environment for machine learning on IoT Edge](https://docs.microsoft.com/azure/iot-edge/tutorial-machine-learning-edge-02-prepare-environment)
    - Set up the development VM
    - Connect to the development VM
    - Install Visual Studio Code extensions

2. Log into the Azure cloud VM as described in the tutorial

   > **Note:**
   If you cannot connect to the VM via RDP, ensure RDP port 3389 is not blocked for the VM. Navigate to the Azure portal and investigate the incoming networking rules. Allowing RDP through 53389 can provide immediate mitigation. There are three steps to change the RDP port. To follow these steps, open the Azure portal and navigate to your virtual machine.
   > 1. Go to 'Run command'. Run the command 'SetRDPPort 53389'.
   > 2. Go to 'Networking' and add an inbound port rule, allowing port 53389.
   > 3. Go to 'Connect' select 'RDP' and change the port number to 53389. Download the generated RDP file.

3. For building the Windows application, install [Visual Studio 2019](https://visualstudio.microsoft.com/downloads/) with the Universal Windows Platform workload. The community edition is sufficient.

4. Clone our interop sample code from GitHub in the VM:

   ```
   git clone https://github.com/microsoft/Windows-IoT-Samples.git
   ```

You are now all set to build the EFLOW VM modules and the Windows application in the Azure cloud VM.

Go to [Next Step](./Setup%20Azure%20Resources.MD)  
