# Text Messaging & Custom Vision Interop Samples
## Progress

- [x] [Introduction](../README.md)   
- [x] [Step 1 - Setup Development Environment](./Setup%20DevVM.MD)   
- [x] [Step 2 - Setup Azure Resources](./Setup%20Azure%20Resources.MD) 
- [x] [Step 3 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD) 
- [ ] **Step 4 - Develop and publish the IoT Edge Linux module**  
- [ ] [Step 5 - Create Certificates for Authentication](./Create%20Certificates%20for%20Authentication.MD)  
- [ ] [Step 6 - Develop the Windows C# UWP Application](./Develop%20the%20Windows%20C%23%20UWP%20Application.MD)
- [ ] [Step 7 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 8 - Run samples](./Run%20samples.MD) 
- [ ] [Troubleshooting](./Troubleshooting.MD) 
---
# Step 4: Develop and publish the IoT Edge Linux module
In this part, we develop and publish the Linux modules in the Windows host using Visual Studio Code.

Build the sample Linux modules in VS Code and add them to your Azure Registry.

1. Open VS Code as an administrator

2. Open the below folder in VS Code based on the sample you are running:
    - Text Messaging: ` Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\textmsg-uwpapp`
    - Custom Vision: `Windows-IoT-Samples\interop-customvision-textmsg-uwpapp\customvision`

3. Create an **.env** file in this folder with the container registry authentication details as variables:

   ```
   CONTAINER_REGISTRY_USERNAME_<registryname>=XXX
   CONTAINER_REGISTRY_PASSWORD_<registryname>=XXX
   ```

4. Replace the two 'XXX' in the .env file by setting the username and password for your container registry as found in the Azure portal. Navigate to your container registry in the Azure portal and go to the tab 'Access Keys'.

5. Replace all occurrences of 'partnercontainerregistry' in the already opened folder with your own registry's name in lower case letters, for example, with 'interopsampleregistry' if you called your registry that way (using VS Code, you can press CTRL+SHIFT+F to search and replace all occurrences).

6. Ensure to be logged in to the Azure portal. VS Code will query you to do so.

7. Ensure the docker daemon is running, if not start it.

8. Also ensure to be logged in with the Azure Registry itself using the credentials shown in the Azure portal:

   ```
   docker login interopsampleregistry.azurecr.io
   ```

9. Right click on the *deployment.template.json* file, click on *Build & push module*

10. Create an IoT Deployment containing the Linux modules and add it to our sample IoT Edge Device:
    - This means to deploy the deployment manifest i.e. deployment.template.json onto your IoT Edge device.
    - Using VS code, follow the steps from the documentation [Deploy Azure IoT Edge modules from Visual Studio Code](https://docs.microsoft.com/azure/iot-edge/how-to-deploy-modules-vscode): 
        - Select 'deployment.template.json', right-click and select 'Generate IoT Edge Deployment Manifest'
        - Choose your subscription, IoT Hub, right-click on the Edge Device and select 'Create Deployment for Single Device'
        - Select the file 'deployment.amd64.json' in the folder 'config' and  push the deployment manifest.

   > **Note:**
   > If the multiple container deploymnet fails, try to push each module separately using the *module.json* file.


Go to [Next Step](./Create%20Certificates%20for%20Authentication.MD) 
