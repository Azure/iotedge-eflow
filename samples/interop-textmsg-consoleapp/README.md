# Interop Console App with Linux Edge Module

## Introduction
This sample demonstrates bidirectional communication between a Windows console application and an Azure IoT Edge module that is running inside the EFLOW VM

The underlying communication between the Windows console application (downstream device) and the IoT Edge module is based on [Advanced Messaging Queuing Protocol (AMQP)](https://docs.microsoft.com/azure/iot-hub/iot-hub-amqp-support), a networking protocol that uses TCP and authenticated using a [public key infrastructure (PKI)](https://en.wikipedia.org/wiki/Public_key_infrastructure).  

### Windows Console Application
The Windows console application in this sample uses the [Microsoft.Azure.Devices.Client](https://docs.microsoft.com/dotnet/api/microsoft.azure.devices.client.deviceclient?view=azure-dotnet) namespace from [Azure IoT libraries for .NET](https://docs.microsoft.com/dotnet/api/overview/azure/iot?view=azure-dotnet).  In this scenario, the Windows console application is being implemented as a [downstream device](https://docs.microsoft.com/azure/iot-edge/how-to-connect-downstream-device), sometimes referred to as a _'leaf device'_. A downstream device can be any application or platform that has an identity created with the Azure IoT Hub cloud service.  A downstream device could even be an application running on the IoT Edge device itself. 

The _'downstream device'_, i.e. Windows console application, uses a root CA certificate, to authenticate with the Azure IoT Edge for Linux instance.  The Azure IoT Edge for Linux instance must be configured to use a certificate and associated private key that resides within the PKI to establish a secure communication channel.  The _'downstream device'_ first authenticates once with Azure IoT Hub (using its downstream device connection string), then IoT Hub authenticates the _'downstream device'_ with the IoT Edge Device as described in [Authenticate a downstream device to Azure IoT Hub](https://docs.microsoft.com/azure/iot-edge/how-to-authenticate-downstream-device).  The connection between the _'downstream device'_ and the IoT Hub is required for the initial authentication but then continues to function when the IoT Edge device is offline.


### Azure IoT Edge Linux based Module 
This sample also incorporates an Azure IoT Edge for Linux module which processes messages sent by the _'downstream device'_ then sends processed results back to the _'downstream device'_ or to the cloud as needed.

### Message Routing
This sample employs concepts described in [Learn how to deploy modules and establish routes in IoT Edge](https://docs.microsoft.com/azure/iot-edge/module-composition) to establish message flow between the _'downstream device'_ (Windows console application) and a custom Azure IoT Edge module. The **IoT Edge Hub system module** ($edgeHub) manages communication between modules, IoT Hub, and downstream devices.  Therefore the $edgeHub module twin contains a _desired property_ called **routes** which declares how messages are passed within a deployment.

The [routing table](https://docs.microsoft.com/azure/iot-edge/module-composition#declare-routes) defines a set of routing entries, where each entry defines a message routing between two endpoints. Each endpoint can be an input or an output of a module. Each module then defines handlers for messages routed to its input endpoint. After processing the message, the module can send a response to one of its output endpoints.

The routing engine uses the module ID to identify the source/destination of a message. However, a downstream device does not have a module ID. Thus, for a module to intercept a message coming from a device, a “special” routing table entry is defined, one that applies to messages with no module ID. This way a ‘device input endpoint’ is created. The processing module can then setup a handler for messages coming from the device input endpoint.

To realize this communication model for the development of both the Windows application and Linux module, we use the below APIs from the Azure Devices Client Namespace provided by the Azure SDK:  

<center>

| Downstream Device (Console App) | Message Direction | Edge Module |
|-------------------|:-----------:|-------------|
| [DeviceClient.SendEventAsync](https://docs.microsoft.com/dotnet/api/microsoft.azure.devices.client.deviceclient.sendeventasync?view=azure-dotnet) | 🠊 🠊 🠊 | [ModuleClient.SetInputMessageHandlerAsync](https://docs.microsoft.com/dotnet/api/microsoft.azure.devices.client.moduleclient.setmessagehandlerasync?view=azure-dotnet) | 
| [DeviceClient.SetMethodHandlerAsync](https://docs.microsoft.com/dotnet/api/microsoft.azure.devices.client.deviceclient.setmethodhandlerasync?view=azure-dotnet) | 🠈 🠈 🠈  | [ModuleClient.InvokeMethodAsync](https://docs.microsoft.com/dotnet/api/microsoft.azure.devices.client.moduleclient.invokemethodasync?view=azure-dotnet) | 

</center>

## Prerequisites
To exercise this sample you will need the following
* An [Azure Subscription](https://azure.microsoft.com/free/) in which you have rights to deploy resources.  

A Windows device with the following minimum requirements:
* System Requirements
   * Windows 10¹/11 (Pro, Enterprise, IoT Enterprise)
   * Windows Server 2019¹/2022  
   <sub>¹ Windows 10 and Windows Server 2019 minimum build 17763 with all current cumulative updates installed.</sub>
* Hardware requirements
  * Minimum Free Memory: 1 GB
  * Minimum Free Disk Space: 10 GB


## Instructions
[Step 1 - Setup Development Environment](./Documentation/Setup%20DevVM.MD)   
[Step 2 - Setup Azure Resources](./Documentation/Setup%20Azure%20Resources.MD)  
[Step 3 - Setup Azure IoT Edge for Linux on Windows](./Documentation/Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)  
[Step 4 - Develop and publish the IoT Edge Linux module](./Documentation/Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
[Step 5 - Create Certificates for Authentication](./Documentation/Create%20Certificates%20for%20Authentication.MD)  
[Step 6 - Develop the Windows C# Console Application](./Documentation/Develop%20the%20Windows%20C%23%20Console%20Application.MD)  
[Step 7 - Configuring the IoT Edge Device](./Documentation/Configuring%20the%20IoT%20Edge%20Device.MD)  
[Step 8 - Deploy the Modules onto the IoT Edge Device](./Documentation/Deploy%20the%20Modules%20onto%20the%20IoT%20Edge%20Device.MD)  
[Step 9 - Run the Console Application](./Documentation/Run%20the%20Console%20Application.MD)  
[Troubleshooting](./Documentation/Troubleshooting.MD)  

## Feedback
If you have problems with this sample, please post an issue in this repository.
