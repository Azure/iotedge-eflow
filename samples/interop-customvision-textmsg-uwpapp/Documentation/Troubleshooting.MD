## Troubleshooting

#### 1. Console message app shows TLS Error ####
This problem is usually caused by a gateway issue. On the IoT Edge device configuration (/etc/iotedge/config.yaml) there's a section called hostname. This automatically gets populated with the system hostname. In some cases, hostname is not found and the user will have to use the EFLOW VM IP. Ensure the gateway name in the C# Windows app matches the hostname in the IoT Edge config.yaml. 

![TLS Error](./Images/TLS_Error.png)

If the previous steps doesn't work, follow these steps:
1. In the config.yaml, change the hostname to the IP address of the EFLOW VM. 
2. `sudo systemctl restart iotedge` 
3. `sudo systemctl status iotedge` - Make sure it says active (running)  
4. `sudo iotedge check` 
5. Run the c# console app using the IP address for the gateway address insted of the hostname


#### 1. Console message app shows TLS Error ####
