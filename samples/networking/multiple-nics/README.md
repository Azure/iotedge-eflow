## Industrial IoT OPC UA - Multiple NIC Support

Suppose in a workflow, you have a networking configuration divided into two different networks/zones. First, you have an offline network, or also defined as the "secure network", which has no internet connectivity, and is limited to internal access. Secondly, you have a demilitarized zone (DMZ), in which you have may a couple of devices, that have limited internet connectivity. When moving the workflow to run on the EFLOW VM, you may have problems accessing the different netowrks since the EFLOW VM by defualt has only one NIC attached. 

This article describes how to configure the EFLOW VM to support multiple NICs and hence get connectivity to multiple networks. With multiple NIC support, applications running on the EFLOW VM can communicate with devices connected to the offline network, and at the same time, use IoT Edge to send data to the cloud.


### The scenario
You have some devices like PLCs or OPC UA compatible devices connected to the offline network, and you want to upload all the device's information to Azure using the [OPC Publisher](https://docs.microsoft.com/en-us/azure/industrial-iot/overview-what-is-opc-publisher) module running on the EFLOW VM.

Since the EFLOW host device and the PLC/OPC UA devices are both physically connected to the offline nework, we can leverage the EFLOW multiple NIC support to connect the EFLOW VM to the offline network. Using an External Virtual Switch, we can get the EFLOW VM connected to the offline network, and has a direct link of communication with all the other offline devices.

On the other end, the EFLOW host device is also physically connected to the DMZ (online network), with internet connectivity, specifically connected to Azure. Using an Internal/External Switch, we can get the EFLOW VM conncted to Azure IoT Hub using IoT Edge modules, and upload the information sent by the offline devices through the offline NIC.

The following diagram shows the architecture described:

![IIoT Multiple NIC Architecture](./../images/iiot-multiplenic.png)