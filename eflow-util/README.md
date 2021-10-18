# EFLOW Util PowerShell functions
Understand EFLOW-Util PowerShell functions that provide further mechanisms to communicate and interact with the EFLOW VM. 

### :warning: Important
 _The following functions are samples codes that are not meant to be used in production deploymnets. Furthemore, functions are subject to change and deletion. Make sure you create your own functions base on these samples._.
 
 
 ## EflowUtil-GetEdgeCertificates
 The **EflowUtil-GetEdgeCertificates** command checks if IoT Edge is configured to use certificates. If so, will display the path of the certificates. 
 This command takes no parameters. It returns an object that contains three properties:
 - Root CA certificate path
 - Device CA certiciate path
 - Private Key path
 
  ## EflowUtil-SetEdgeCertificates
 The [**EflowUtil-SetEdgeCertificates**](./EflowUtil-SetEdgeCertificates.ps1) command sets the IoT Edge certificates in the virtual machine. The command handles copying the certificates into the EFLOW VM, assign the needed permissions, and configure IoT Edge. Use the optional parameters to define specific file/folder for configuration.
 
| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| _rootCAPath_ | Root CA source path on Windows | Root CA it's the topmost certificate authority for the IoT Edge scenario. |
| _deviceCACertificatePath_ | Device CA Certificate path on Windows | - |
| _deviceCAPrivateKeyPath_ | Device CA Private Key path on Windows | - |
| identityCertDirVm |  Certificates folder path on CBL-Mariner (EFLOW VM) | **Optional** |
| _deviceCAPrivateKeyPath_ |  Private Key folder path on CBL-Mariner (EFLOW VM) | **Optional** |
