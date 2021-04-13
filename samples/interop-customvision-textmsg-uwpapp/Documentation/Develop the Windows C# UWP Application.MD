# Text Messaging & Custom Vision Interop Samples
## Progress

- [x] [Introduction](../README.md)  
- [x] [Step 1 - Setup Development Environment](./Setup%20DevVM.MD)   
- [x] [Step 2 - Setup Azure Resources](./Setup%20Azure%20Resources.MD)
- [x] [Step 3 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)  
- [x] [Step 4 - Develop and publish the IoT Edge Linux module](./Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
- [x] [Step 5 - Create Certificates for Authentication](./Create%20Certificates%20for%20Authentication.MD)  
- [ ] **Step 6 - Develop the Windows C# Console Application**  
- [ ] [Step 7 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 8 - Run samples](./Run%20samples.MD)  
- [ ] [Troubleshooting](./Troubleshooting.MD) 
---
# Step 6: Develop the Windows C# UWP Application
This part describes how to develop the Windows console application in the development VM. Build the Windows application as an [application package in Visual Studio](https://docs.microsoft.com/windows/msix/package/packaging-uwp-apps):

1 Open the below Windows application based on the sample you are running - Use Visual Studio running as Admin.
   - Text Messaging: `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\textmsg-uwpapp\LeafDeviceUWPApp\LeafDeviceUWPApp.sln`
   - Custom Vision: `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\customvision\DeviceCustomVisionUWPApp\DeviceCustomVisionUWPApp.sln`

   > **Note:**
   > For certificate installation, make sure you include the certificate created on Step 5. The folder should be .\devicetestcertificates\certs

2. On the top pane, set build to 'Debug' and select the 'x64' architecture, and build the project.

3. To be able to run the application on the Windows device, build the application as an 'App package' according to [Package a desktop or UWP app in Visual Studio](https://docs.microsoft.com/windows/msix/package/packaging-uwp-apps).

   > **Note:**
   > Select sideloading without automatic updates
   > You will be prompted to create a certificate. As this is a test setup, you can create the test certificates for which VS offers an option in the process

4. The output path for UWP package can be found in the below location.
   - Text Messaging: `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\textmsg-uwpapp\LeafDeviceUWPApp\AppPackages\LeafDeviceUWPApp_1.0.0.0_Debug_Test`
   - Custom Vision: `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\customvision\DeviceCustomVisionUWPApp\AppPackages\DeviceCustomVisionUWPApp _1.0.0.0_Debug_Test`

5. Install the Windows application's dependencies. The Windows host may lack dependencies that are found in the below folders - Ensure to install all the dependencies needed for the the sample used.

   - Text Messaging
   `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\textmsg-uwpapp\LeafDeviceUWPApp\AppPackages\LeafDeviceUWPApp_1.0.0.0_Debug_Test\Dependencies`

   - Custom Vision
   `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\customvision\DeviceCustomVisionUWPApp\AppPackages\DeviceCustomVisionUWPApp_1.0.0.0_Debug_Test\Dependencies`

6. Install the signing certificate for the Windows sample application from the 'package' folder. Install the certificate to your local machine into the 'Trusted Root' store. This ensures that Windows will install and execute the application binary.

7. Install the MSIX bundle in the application package folder (a file called as below based on the running sample). The app can now be found on the system, as...
   - Text Messaging: **Azure IoT Edge for windows on Linux interop sample**
   - Custom Vision:  **UWP - Edge interop**


Go to [Next Step](./Configuring%20the%20IoT%20Edge%20Device.MD)  
