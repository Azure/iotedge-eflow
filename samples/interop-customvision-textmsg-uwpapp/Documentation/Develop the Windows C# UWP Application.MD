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
---
# Step 6: Develop the Windows C# UWP Application
This part describes how to develop the Windows console application in the development VM. You can follow the [Build and run a C++ console app project](https://docs.microsoft.com/cpp/build/vscpp-step-2-build) guide.

1 Open the Windows application sample - Use Visual Studio running as Admin.
   - Network Media Streamer: `WinUSBtoRTSP\NetworkMediaStreamer.sln`

2. On the top pane, set build to 'Release' and select the 'x64' architecture, and build the project.

3. The output path for .exe package can be found in the below location.
   -Network Media Streamer: `WinUSBtoRTSP\CameraRTSPStreamerApp.sl

5. Install the Windows application's dependencies. The Windows host may lack dependencies that are found in the below folders - install of each of these.

   - Text Messaging
   `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\textmsg-uwpapp\LeafDeviceUWPApp\AppPackages\LeafDeviceUWPApp_1.0.0.0_Debug_Test\Dependencies`

   - Custom Vision
   `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\customvision\DeviceCustomVisionUWPApp\AppPackages\DeviceCustomVisionUWPApp_1.0.0.0_Debug_Test\Dependencies`

6. Install the signing certificate for the Windows sample application from the 'package' folder. Install the certificate to your local machine into the 'Trusted Root' store. This ensures that Windows will install and execute the application binary.

7. Install the MSIX bundle in the application package folder (a file called as below based on the running sample). The app can now be found on the system, as...
   - Text Messaging: **Azure IoT Edge for windows on Linux interop sample**
   - Custom Vision:  **UWP - Edge interop**


Go to [Next Step](./Configuring%20the%20IoT%20Edge%20Device.MD)  
