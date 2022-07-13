# EFLOW Util PowerShell functions

Understand EFLOW-Util PowerShell functions that provide extra mechanisms to connect and disconnect USB devices to the EFLOW VM.

### :warning: Important
_The following functions are samples codes that are not meant to be used in production deployments. Furthermore, functions are subject to change and deletion. Make sure you create your own functions based on these samples._.

## Get-EflowUSBDevices

The [**Get-EflowUSBDevices**](./Get-EflowUSBDevices.ps1) lists all of the USB devices connected to Windows that could be attached to the EFLOW virtual machine.
This command takes no parameters. It prints out a table that contains four properties:

- BUSID
- VID:PID
- Device
- State

## Add-EflowUSBDevices

The [**Add-EflowUSBDevices**](./Add-EflowUSBDevices.ps1) command connects the USB device to the EFLOW virtual machine

| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| busId | String | Bus-id assigned by Windows to the USB device. |
| hostIp | String IP4Address | IP address of the Windows host OS |

## Remove-EflowUSBDevices

The [**Remove-EflowUSBDevices**](./Remove-EflowUSBDevices.ps1) command disconnects the USB device to the EFLOW virtual machine

| Parameter | Accepted values | Comments |
| --------- | --------------- | -------- |
| busId | String | Bus-id assigned by Windows to the USB device. |
| hostIp | String IP4Address | IP address of the Windows host OS |
