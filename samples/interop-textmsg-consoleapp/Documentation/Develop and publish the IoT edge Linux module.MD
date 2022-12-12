# Interop Console App with Linux Edge Module
## Progress

- [x] [Introduction](../README.md)   
- [x] [Step 1 - Setup Azure Resources](./Setup%20Azure%20Resources.MD) 
- [x] [Step 2 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD) 
- [ ] **Step 3 - Develop and publish the IoT Edge Linux module**  
- [ ] [Step 4 - Create Certificates for Authentication](./Create%20Certificates%20for%20Authentication.MD)  
- [ ] [Step 5 - Develop the Windows C# Console Application](./Develop%20the%20Windows%20C%23%20Console%20Application.MD)  
- [ ] [Step 6 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 7 - Deploy the Modules onto the IoT Edge Device](./Deploy%20the%20Modules%20onto%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 8 - Run the Console Application](./Run%20the%20Console%20Application.MD)  
- [ ] [Troubleshooting](./Troubleshooting.MD)  
---
# Step 3: Develop and publish the IoT edge Linux module
In this part we develop and publish the Linux modules in the development VM using Visual Studio Code.


1. [Create a new project](#CreateProject)  
1. [Add your registry credentials](#AddRegistryCredentials)  
1. [Update the module with custom code](#UpdateModule)
1. [Build and push your module](#BuildAndPush)   

> **Note:** The C# solution created in the following steps is included in our sample repo. You can use the downloaded sample code and run it

---  
<a name="CreateProject"></a>  

## Create a new project  
Create a C# solution template that you can customize with your own code.  

1. In Visual Studio Code, select **View** > **Command Palette** to open the VS Code command palette.  

1. In the command palette, enter and run the command **Azure: Sign in** and follow the instructions to sign in your Azure account. If you're already signed in, you can skip this step.  

1. In the command palette, enter and run the command **Azure IoT Edge: New IoT Edge solution**. Follow the prompts in the command palette to create your solution.  
   | Field                                          | Value |  
   |------------------------------------------------|-------|  
   | Select folder                                  | Choose the location on your development machine for VS Code to create the solution files. |
   | Provide a solution name                        | Enter a descriptive name for your solution or accept the default **EdgeSolution**.  |
   | Select module template	                        | Choose **C# Module**. |
   | Provide a module name	                        | Name your module **SampleModule**.|
   | Provide Docker image repository for the module	| An image repository includes the name of your container registry and the name of your container image. Your container image is prepopulated from the name you provided in the last step. Replace **localhost:5000** with the **Login server** value from your Azure container registry. You can retrieve the Login server from the Overview page of your container registry in the Azure portal. <br /> <br />The final image repository looks like `<registry name>.azurecr.io/SampleModule`.|

---
<a name="AddRegistryCredentials"></a>  

## Add your registry credentials
The environment file stores the credentials for your container registry and shares them with the IoT Edge runtime. The runtime needs these credentials to pull your private images onto the IoT Edge device. Use the credentials from the **Access keys** section of your Azure container registry.

The IoT Edge extension tries to pull your container registry credentials from Azure and populate them in the environment file. Check to see if your credentials are already included. If not, add them now:

1. In the VS Code explorer, open the **.env** file.
1. Update the fields with the **username** and **password** values from your Azure container registry.
1. Save this file.

---
<a name="UpdateModule"></a>  

## Update the module with custom code
1. In the VS Code explorer, open **modules** > **SampleModule** > **ModuleBackgroundService.cs**.

1. At the top of the **SampleModule** namespace, add the following **using** statement:
   ```chsarp
   using Newtonsoft.Json;                // For JsonConvert
   ```

1. Add the following **UtcDateTime** utility method to the class **ModuleBackgroundService**.  
    ```chsarp
    string UtcDateTime
    {
        get
        {
            return DateTime.Now.ToUniversalTime().ToString("G");
        }
    }
    ```

1. Add the **SendMessageToLeafDevice** method to the class **ModuleBackgroundService**. 

    ```csharp
    /// <summary>
    /// This method uses 'moduleClient.InvokeMethodAsync to send messages to leaf device.
    /// </summary>
    async Task SendMessageToLeafDevice(string deviceId, ModuleClient moduleClient )
    {
        try
        {
            string message = $"Hello from edge!";
            string jString = JsonConvert.SerializeObject(message);
            var methodRequest = new MethodRequest("LeafDeviceDirectMethod", Encoding. UTF8.GetBytes(jString));
            var response = await moduleClient.InvokeMethodAsync(deviceId, methodRequest);
            if(response.Status == 200)
            {
                _logger.LogInformation($"{UtcDateTime} sent message:{message}");
            }
            else
            {
                _logger.LogError($"Error occurred invoking LeafDeviceDirectMethod. error status code {response.Status}");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"SendMessageToLeafDevice got exception {ex.Message}");
        }
    }
    ```

1.  Replace the **ProcessMessageAsync** method implementation with the following implementation which will be invoked upon messages received from Windows application.
    ```csharp
    /// <summary>
    /// This method is called whenever a leaf device sent a message to edge. 
    /// </summary>
    async Task<MessageResponse> ProcessMessageAsync(Message message, object userContext)
    {
        try
        {
            int counterValue = Interlocked.Increment(ref _counter);

            var moduleClient = userContext as ModuleClient;
            if (moduleClient == null)
            {
                throw new InvalidOperationException("UserContext doesn't contain " + "expected values");
            }

            byte[] messageBytes = message.GetBytes();
            string messageString = Encoding.UTF8.GetString(messageBytes);
            _logger.LogInformation("Received message: {counterValue}, Body: [{messageString}]", counterValue, messageString);

            if (!string.IsNullOrEmpty(messageString))
            {
                await SendMessageToLeafDevice(message.ConnectionDeviceId, moduleClient);
                _logger.LogInformation("Received message sent");
            }
        }
        catch (System.Exception ex)
        {
             _logger.LogError($"Exception occurred {ex.StackTrace}");
        }
        return MessageResponse.Completed;
    }
    ```

1. Save the ModuleBackgroundService.cs file

1. In the VS Code explorer, open the **deployment.template.json** file in your IoT Edge solution workspace.

1. Replace all entries in **routes** with the following code to redirect the messages received from the windows application to SampleModule.
   ```json
   "leafdeviceinputendpoint": "FROM /messages/* WHERE NOT IS_DEFINED($connectionModuleId) INTO BrokeredEndpoint(\"/modules/SampleModule/inputs/leafdeviceinput\")"
   ```

1. Remove the following entry for **SimulatedTemperatureSensor** module from deployment.template.json as it is not for this sample.
   ```json
   ,
             "SimulatedTemperatureSensor": {
               "version": "1.0",
               "type": "docker",
               "status": "running",
               "restartPolicy": "always",
               "settings": {
                 "image": "mcr.microsoft.com/azureiotedge-simulated-temperature-sensor:1.0",
                 "createOptions": {}
               }
   }
   ```


1. Create an **.env** file in this folder with the container registry authentication details as variables:

   ```
   CONTAINER_REGISTRY_USERNAME_<registryname>=XXX
   CONTAINER_REGISTRY_PASSWORD_<registryname>=XXX
   ```
  
   
1. Check your registry credentials of the deployment.template.json file (under *registryCredentials*), and set <registryname> to the name of your container registry:
   ```json
   <registryname>": { "username": "$CONTAINER_REGISTRY_USERNAME_<registryname>", "password": "$CONTAINER_REGISTRY_PASSWORD_<registryname>", "address": "<registryname>.azurecr.io" }
   ```
1. Save the file deployment.template.json

1. In the VS Code explorer, open the **modules/SampleModule/module.json** file in your IoT Edge solution workspace.

   Ensure your registry name is set in the modules/SampleModule/module.json (see former “Create new project” step):
   ```json
   … "repository": "<registryname>.azurecr.io" …
   ```

---
<a name="BuildAndPush"></a>

## **Build and push your module**  
In the previous section, you created an IoT Edge solution and added code to the SampleModule. Now you need to build the solution as a container image and push it to your container registry.

1. Open the VS Code integrated terminal by selecting **View** > **Terminal**.

1. Sign in to Docker by entering the following command in the terminal. Sign in with the username, password, and login server from your Azure container registry. You can retrieve these values from the **Access keys** section of your registry in the Azure portal.

   ```bash
   docker login -u <ACR username> -p <ACR password> <ACR login server>
   ```
   You may receive a security warning recommending the use of --password-stdin. While that best practice is recommended for production scenarios, it's outside the scope of this tutorial. For more information, see the docker login reference.

1. In the VS Code explorer, right-click the **deployment.template.json** file and select **Build and Push IoT Edge Solution**.

   The build and push command starts three operations. First, it creates a new folder in the solution called **config** that holds the full deployment manifest, built out of information in the deployment template and other solution files. Second, it runs docker build to build the container image based on the appropriate dockerfile for your target architecture. Then, it runs docker push to push the image repository to your container registry.

   This process may take several minutes the first time, but is faster the next time that you run the commands.

Go to [Next Step](./Create%20Certificates%20for%20Authentication.MD) 
