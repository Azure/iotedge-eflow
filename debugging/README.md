# Build & Debug IoT Edge C# Linux Module with Visual Studio and EFLOW

Azure IoT Edge for Linux on Windows (EFLOW) allows you to easily develop, debug and deploy Azure IoT Edge Linux modules on top of a Windows device. To learn more about EFLOW, and Azure IoT Edge Tools, you can refer to the following documents:
-	[What is Azure IoT Edge for Linux on Windows](https://docs.microsoft.com/en-us/azure/iot-edge/iot-edge-for-linux-on-windows?view=iotedge-2018-06#:~:text=Azure%20IoT%20Edge%20for%20Linux%20on%20Windows%20allows%20you%20to,solutions%20being%20built%20in%20Linux.)
-	[Develop and debug modules in Visual Studio - Azure IoT Edge](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-visual-studio-develop-module?view=iotedge-2020-11)

Building and remote debugging a module running inside the EFLOW VM is not straightforward. Therefore, this tutorial aims to demonstrate how to build a Linux C# module, push it to an ACR, and remotely debug it running inside EFLOW from the Window host OS. 

## Prerequisites
-	Windows device (Server/Client) running EFLOW. To learn more about EFLOW Installation and provisioning, check [Create and provision an IoT Edge for Linux on Windows device using symmetric keys - Azure IoT Edge.](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-provision-single-device-linux-on-windows-symmetric?view=iotedge-2018-06&tabs=azure-portal%2Cpowershell)
-	Visual Studio 2019/2022
-	Azure IoT Edge Tools extension for Visual Studio
-	Docker Desktop on Windows¹
      
     <sub>¹ Only needed if building the module using Windows Docker instance. Not required if following Step 8</sub>

## Build & Debug C# Linux Module Container Running in EFLOW Edge Device


1)	Open Visual Studio 2019/2022 and click menu **File** -> **New** -> **Project**. In the New Project dialog, select **Platform** -> **Linux**, select **Project** **Type** -> **IoT**, and then choose **Azure IoT Edge (Linux amd64)**. Next, enter a name for your project, specify the location, and select **OK**.

      <p align="left"><img src="./Images/NewProject.png" height="350"/></p>

2)	In the project wizard, select C# Module, and replace **localhost:5000** with your **own registry info**, then click **Yes**

      <p align="left"><img src="./Images/AddModule.png" height="400"/></p>

      _Note: If using the iotedgemodule1 name for the module, make sure you only only replace localhost:5000 with user’s registry info. If using another module name, change the name in the upcoming steps also._

3)	There are two projects in the solution:
      -  One is the IoT Edge module project, which is just a simple C# project
      -  The other, the Edge project, is called the same as you’re the Visual Studio solution.

      <p align="left"><img src="./Images/Solution.png" height="300"/></p>


4)	To debug the C# Linux module, we need to update **Dockerfile.amd64.debug** to enable SSH service. Update the **Dockerfile.amd64.debug** file to use the following template: [Dockerfile for Azure IoT Edge AMD64 C# Module with Remote Debug Support](./Dockerfile.amd64.debug)

      _Note: The “EXPOSE 22” line will expose the port 22 (SSH Port) of the module. Using the deployment manifest, this port can be binded to another EFLOW VM port._

5)	To establish an SSH connection with the Linux module, we need to create an RSA key. Open an elevated PowerShell session and run the following commands to create a new RSA key. 

     :warning: **Important:  _When asked for a directory, use the folder path where the IoTEdgeModule1 is stored_.**
     
     `ssh-keygen -t RSA -b 4096 -m PEM`

      <p align="left"><img src="./Images/Ssh-keygen.png" width="800"/></p> 

      _Note: If you strictly follow Step 4, key names must be id_rsa and id_rsa.pub. Make sure that the id_rsa and id_rsa.pub key files are created inside the same folder as the IoTEdgeModule1 project. If not, copy the files or the module building process will fail._

6)	If you’re using a private registry like Azure Container Registry, use the following Docker command to sign in.

     `docker login -u <ACR username> -p <ACR password> <ACR login server>`

     _Note: Make sure to use username and password from container registry’s Access key, not the one for Azure portal._

7)	Click **Show All Files** icon as below; a **.env** file should be displayed under the Edge project, named as your VS solution. Open the .env file to input credentials for your registry. These credentials will be used by IoT Edge runtime to pull/push module Images after deployment. If the .env file is not created, go to the project folder, and make sure it’s not being hidden.

8) **OPTIONAL: Build the module using moby-engine running inside the EFLOW VM**

      This step is **optional** is you have Docker Desktop installed. If you do not have Docker Desktop, you will have to use the moby-engine from the EFLOW VM, hence this step is **required**.

      1) Open the Docker port inside the EFLOW VM. Using an elevated PowerShell session, run the following command:
                  
            `Invoke-EflowVmCommand "sudo iptables -A INPUT -p tcp --dport 2375 -j ACCEPT"` 

      2) Get the EFLOW VM IP address. Using an elevated PowerShell session, run the following command:

            `Get-EflowVmAddr`

      3) Connect to the EFLOW VM
      
            `Connect-EflowVm`

      4) Once inside the VM use the following commands:

            1) Copy the docker.service to the system folder: `sudo cp /lib/systemd/system/docker.service /etc/systemd/system/docker.service`

            2) Edit the docker.service: `sudo nano /etc/systemd/system/docker.service`

            3) Change the following section: `ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock`
             
               With: `ExecStart=/usr/bin/dockerd -H fd://  -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock`

            4) Save the file using Ctrl + O

            5) Reload the services configurations: `sudo systemctl daemon-reload`

            6) Restart the Docker service: `sudo systemctl restart docker.service`

            7) Check Docker is listening to external connections: `sudo netstat -lntp |grep dockerd`

                  <p align="left"><img src="./Images/DockerD.png" width="500"/></p>

      5) Go to **Tools** -> **Azure IoTEdge Tools** -> **IoT Edge Tools Settings…**

      6) Replace the _DOCKER_HOST_ localhost value with the EFLOW VM IP from Step 8.2

            <p align="left"><img src="./Images/VsDocker.png" height="350"/></p>


9)	Right-click on the Edge project and click **Build and Push IoT Edge Modules** to build, push the C# module to the container registry.

10)	Next, you’ll have to deploy the built module to the EFLOW device. There are multiple ways to deploy a module to an IoT Edge device. You may use the one you’re most comfortable with. For deployments using Azure:

     1) Go to Azure Portal
     2) Go to the IoT Edge device provisioned to the EFLOW VM
     3) Set Modules and add the recently built.
     4) We need to expose port 22 to access the module SSH service. For the purpose of this example,  we use 10022 as the host port, but you may specify a different port, which will be used as an SSH port to connect into the Linux C# moduler. If another module is already using the port 10022, make sure to use another port number, otherwise the module will fail to start. Under “Container Create Options” make sure to include the following:

      ```yaml
      {
          "HostConfig": {
              "Privileged": true,
              "PortBindings": {
                  "22/tcp": [
                      {
                          "HostPort": "10022"
                      }
                  ]
              }
          }
      }
      ```
            
11)	Open an elevated PowerShell session
    1) Get the moduleId based on the name used for the Linux C# module
    
        `$moduleId = Invoke-EflowVmCommand “sudo docker ps -aqf name=<iot-edge-module-name>”`
      
    2) Check that the $moduleId is correct – If the variable is empty, make sure you’re using the correct module name
    3) Start the SSH service inside the Linux container
    
       `Invoke-EflowVmCommand “sudo docker exec -it -d $moduleId service ssh start”`
    
    4) Open the module SSH port on the EFLOW VM (in our case was 10022)
    
       `Invoke-EflowVmCommand “sudo iptables -A INPUT -p tcp --dport 10022 -j ACCEPT”`

      _Note: For security reasons, every time the EFLOW VM reboots, the IP table rule will delete and go back to the original settings. Also, the module SSH service will have to be started again manually._

12)	After successfully starting SSH service, click **Debug** -> **Attach to Process**, set Connection Type to SSH, and Connection target to the IP address of your EFLOW VM. If you don’t know the EFLOW VM IP, you can use the `Get-EflowVmAddr` cmdlet. First, type the IP and then press enter. In the pop-up window, input the following configurations:

      | Field               | Value                                                         |
      |---------------------|---------------------------------------------------------------|
      | **Hostname**            | Use the EFLOW VM IP                                           |
      | **Port**                | 10022 (Or the one you used in your deployment configuration)  |
      | **Username**            | root                                                          |
      | **Authentication type** | Private Key                                                   |
      | **Private Key File**    | Full path to the id_rsa that was previously created in Step 5 |
      | **Passphrase**          | The one used for the key created in Step 5                    |
      
      <p align="left"><img src="./Images/ConnectRemoteSystem.png" height="400"/></p>


13) If it’s the first time you are establishing a connection with the module, you’ll ask to Accept the Host Key for the SSH connection. Press “Yes”

      <p align="left"><img src="./Images/Fingerprint.png" width="250"/></p>

      After clicking Yes,  you should be ok to start debugging. If you are still blocked, please double check if anything at Steps (4), (5), (9), (10) is not correct.

12)	After successfully connecting to the module using SSH, then you can choose the process and click **Attach**. For the C# module you need to choose process **dotnet** and **“Attach to” to Managed (CoreCLR).**
 
      <p align="left"><img src="./Images/AttachToProcess.png" height="400"/></p>

13)	Now you can set breakpoint and debug your C# Linux module from Visual Studio on Windows. 

      <p align="left"><img src="./Images/DebugCode.png" height="400"/></p>
