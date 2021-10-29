# Industrial IoT OPC UA - Multiple NIC Support

Suppose in a workflow, you have a networking configuration divided into two different networks/zones. First, you have a Secure network, or also defined as the offline network, which has no internet connectivity, and is limited to internal access. Secondly, you have a demilitarized zone (DMZ), in which you have may a couple of devices, that have limited internet connectivity. When moving the workflow to run on the EFLOW VM, you may have problems accessing the different netowrks since the EFLOW VM by defualt has only one NIC attached. 

This article describes how to configure the EFLOW VM to support multiple NICs and hence get connectivity to multiple networks. With multiple NIC support, applications running on the EFLOW VM can communicate with devices connected to the offline network, and at the same time, use IoT Edge to send data to the cloud.


## The scenario
You have some devices like PLCs or OPC UA compatible devices connected to the offline network, and you want to upload all the device's information to Azure using the [OPC Publisher](https://docs.microsoft.com/en-us/azure/industrial-iot/overview-what-is-opc-publisher) module running on the EFLOW VM.

Since the EFLOW host device and the PLC/OPC UA devices are both physically connected to the offline nework, we can leverage the EFLOW multiple NIC support to connect the EFLOW VM to the offline network. Using an External Virtual Switch, we can get the EFLOW VM connected to the offline network, and has a direct link of communication with all the other offline devices.

On the other end, the EFLOW host device is also physically connected to the DMZ (online network), with internet connectivity, specifically connected to Azure. Using an Internal/External Switch, we can get the EFLOW VM conncted to Azure IoT Hub using IoT Edge modules, and upload the information sent by the offline devices through the offline NIC.

The following diagram shows the architecture described:

![IIoT Multiple NIC Architecture](./../images/iiot-multiplenic.png)

We can summarize the requirements:

- For the Secure nework:
  - No internet connectivity, access restrcited.
  - PLCs or UPC UA compatible devices connected.
  - EFLOW VM connected using an External virtual swtich.

- For the DMZ:
  - Internet connnectivity - Azure connection allowed.
  - EFLOW VM connected to Azure IoT Hub, using either an Internal/External virtual switch.
  - OPC Publisher running as a module inside the EFLOW VM used to publish data to Azure.


## Configure OPC UA devices
In order to test the scenario described above, we will simulate OPC UA devices. To do so, there are different OPC UA Server simulators, in particular we will use [Prosys OPC UA Simulation Server](https://www.prosysopc.com/products/opc-ua-simulation-server/). This program will simulate OPC UA traffic, that we will publish to Azure using OPC UA Publisher module. 

### Setup OPC UA Server Simulator
1. Download [Prosys OPC UA Simulation Server](https://www.prosysopc.com/products/opc-ua-simulation-server/evaluate/).
2. Run the installer.
3. Run Prosys OPC UA Simulation Server.
4. Navigate to Objects, and check the simulated parameters. If needed, change the Name and the value creation method.
5. Make sure the Simulator is Running.

![OPC UA Simlulation Server](./../images/Prosys-OPC-UA-Simulator.png)

### Check IP configuration
1. Open a PowerShell session.
2. Run the command `ipconfig`.
3. Check the IP configuration - Make sure you get the IP Address of the switch that is connected to the offline network. In our case, it's the Ehternet adapter, with the IP Address 192.168.2.1

![OPC UA Device IP](./../images/OPC-UA-IP.png)


## Configure EFLOW device
The EFLOW device will act as a gateway, and upload the data from the OPC UA Simulation Server to Azure using the OPC Publisher module. To do so, the EFLOW VM needs to be connected to both the Secure network (offline) and the DMZ netwrok (online).
The following steps will guide you how to setup the EFLOW VM, check connectivity with OPC UA Simulation Server, add a second NIC to the EFLOW VM, and finally configure OPC UA Publisher module to upload the data.

### Check connectivity to the OPC UA Simulation Server
Before installing EFLOW and connectiong the OPC UA Publisher to the offline devices, we will test that the Windows host can access the OPC UA Simulation Server data. To do so, there are different OPC UA Clients, in particular we will use [Prosys OPC UA Client](https://downloads.prosysopc.com/opc-ua-client-downloads.php). 

1. Download [Prosys OPC UA Client](https://www.prosysopc.com/opcua/apps/JavaClient/dist/3.2.0-328/prosys-opc-ua-client-3.2.0-328.exe).
2. Run the installer.
3. Run Prosys OPC UA Client.
4. Get the Connection string from the OPC UA Simulation Server.
5. Copy the Connection string inside the OPC UA Client, and connect.
6. When asked about Security Settings, chose your OPC UA Simulation Server settings (by default None).
7. Check the incoming data under Objects -> Simulation

![OPC UA Client](./../images/Prosys-OPC-UA-Client.png)

