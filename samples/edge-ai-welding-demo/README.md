# Weld Porosity Solution Setup Guide

# Prerequisites
1. An edge machine with Ubuntu/WSL2.
2. Azure Account with active suscription. Follow [this documentation](https://azure.microsoft.com/en-us/free/
) for know more about Creating Azure Account.

# Setup
## Setting up Development machine

> Note: Follow [this](https://docs.microsoft.com/en-us/windows/wsl/install) document for setting up Windows Subsystem For Linux (WSL2) on your Windows machine.

Complete the following steps to setup the deployment machine.
1. [Install Docker](https://docs.docker.com/engine/install/ubuntu/)
    > Note: Add the non-root user to the docker group by following [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).
2. [Install Visual Studio Code](https://code.visualstudio.com/download)
3. Install [Azure IoT Tools Extension](https://marketplace.visualstudio.com/items?itemName=vsciot-vscode.azure-iot-tools) for visual studio code.

## Setting up Cloud Resources
1. Create [Azure Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups)
2. Create [Azure IoT Hub](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-create-through-portal#create-an-iot-hub)

<a id="iotedge"> </a>

3. Create Azure IoT Edge Device using [Register your device](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-provision-single-device-linux-symmetric?view=iotedge-2020-11&tabs=azure-portal#register-your-device) section.

<a id="container-registry"> </a>

4. Create [Azure Container Registry](https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/edge/get-started-detect-motion-emit-events-portal#create-a-container-registry).


## Setting up Deployment Machine

1. Setting up the ELOW on your Windows deployment machine.

    Follow [Create and provision an IoT Edge for Linux on Windows device using symmetric keys](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-provision-single-device-linux-on-windows-symmetric?view=iotedge-2018-06&tabs=azure-portal%2Cpowershell) document to setup the EFLOW on your deployment Windows machine.


# Deploying the Solution
> Note: This step assumes that you have successfully completed installing EFLOW on your deployment Windows machine.

> These steps needs to be done from your development machine **not** deployment machine. 
## Connect Visual Studio Code to the IoT Hub
1. Follow [Obtain your IoT Hub connection string](https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/edge/get-started-detect-motion-emit-events-portal#obtain-your-iot-hub-connection-string) to copy your IoT Hub connection string.
2. Open the **Explorer** tab by naviagting to **View > Explorer** on the Visual Studio Code
2.  Open **Azure IOT HUB** from the lower-left corner of your visual studio code on **Explore Tab**.
3.  Click on the **More Action** to set the IoT Hub Connection string and paste the Primary Connection String copied on step 1 on the pop up input box shown and press **Enter** key.
4. After successfull setup, **Azure IOT HUB** from the lower-left corner of your visual studio code will list the IoT Edge Devices under your Azure IoT Hub.

## Building and Pushing Docker images
1. Open the cloned repo in the Visual Studio Code using **File > Open Folder**
2. Expand the **src** folder.
3. Update the **.env** file with the following details
    
    * `CONTAINER_REGISTRY_USERNAME` and `CONTAINER_REGISTRY_PASSWORD` from the container registry created on step [Create Azure Container Registry](#container-registry).
    
        * Navigate to **Settings > Access Keys** and enable Admin User.
        * use the **Registry name** and **password** to update the file.
    * `INPUT` needs to be updated with the RTSP stream URL. By defult it will use the URL `rtsp://rtspsim:8554/input.mp4` which is an rtsp stream simulated by the `rtspsim` module.

4. Right click on the `src/deployment.template.json` and then select **Build and Push IoT Edge Solution**.

## Deploying the Solution
Continue to deploy the solution to your deployment machine once all the module are build and pushed.

1. Right clik on the `config/deployment.amd64.json` file and select **Generate Deployment for Single Device**.
2. Selet the IoT Edge Device ID on the pop box that appears.
3. An OUTPUT window will pop up confirming that the deployment has succeeded.

## Verify the deployment

The deployment can be verified in multiple ways, here we will be verifying the deployment directly on deployment Windows machine.

1. Open a **Power Shell** on your deployment machine.
2. Run the following command to ssh to the EFLOW virtual machine from your windows machine.

    ```sh
    Connect-EflowVM
    ```
2. Run the following command to list all the deployed modules

    ```sh
    sudo iotedge list
    ```
3. Wait until the following modules appear on the list with status as running
    * edgeAgent
    * edgeHub
    * telegraf
    * pipeline
    * rtsp
    * MQTTBroker
    * opcua
    * influxdb

    Run the command on step 2 to recheck the module status.

The same can be viewed from
* Visual Studio Code - Azure IOT HUB panel
* Azure IoT Hub portal
* Windows Admin Center dashboard

## Setting up Simulator on Windows

To setup simulator applications on Windows, follow [this](./simulator.md#setting-up-simulator-on-windows) document

## Visualize Weld Porosity Edge UI on Windows
To visualize the weld porosity edge UI on windows machine, refer [this](./simulator.md#visualize-weld-porosity-edge-ui-on-windows) documentation.
