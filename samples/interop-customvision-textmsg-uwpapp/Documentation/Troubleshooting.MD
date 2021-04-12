## Troubleshooting

#### 1. Console message app shows TLS Error ####
This problem is usually caused by a gateway issue. On the IoT Edge device configuration (/etc/iotedge/config.yaml) there's a section called hostname. This automatically gets populated with the system hostname. In some cases, hostname is not found and the user will have to use the EFLOW VM IP. Ensure the gateway name in the C# Windows app matches the hostname in the IoT Edge config.yaml. 

![TLS Error](./Images/TLS_Error.png)
