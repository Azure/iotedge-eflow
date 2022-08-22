# EFLOW Util Edge Certificates functions

Understand EFLOW-Util EdgeCertificates PowerShell functions that provide extra mechanisms to copy and set certificates inside the EFLOW VM.

### :warning: Important
_The following functions are samples codes that are not meant to be used in production deployments. Furthermore, functions are subject to change and deletion. Make sure you create your own functions based on these samples._.

## Get-EflowVmEdgeCertificates

The [**Get-EflowVmEdgeCertificates**](./Get-EdgeCertificates.ps1) command checks if IoT Edge is configured to use certificates. If so, it will display the path of the certificates. 
This command takes no parameters. It returns an object that contains three properties:

- Root CA certificate path
- Device CA certificate path
- Private Key path

## Set-EflowVmEdgeCertificates

The [**Set-EflowVmEdgeCertificates**](./Set-EdgeCertificates.ps1) command sets the IoT Edge certificates in the virtual machine. The command handles copying the certificates into the EFLOW VM, assigning the needed permissions, and configuring IoT Edge. Use the optional parameters to define a specific file/folder for configuration.

| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _rootCAPath_ | Root CA source path on Windows | Root CA it is the topmost certificate authority for the IoT Edge scenario. |
| _deviceCACertificatePath_ | Device CA Certificate path on Windows | - |
| _deviceCAPrivateKeyPath_ | Device CA Private Key path on Windows | - |
| identityCertDirVm |  Certificates folder path on CBL-Mariner (EFLOW VM) | **Optional** |
| _deviceCAPrivateKeyPath_ |  Private Key folder path on CBL-Mariner (EFLOW VM) | **Optional** |