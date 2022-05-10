# EFLOW Remote Deploy

eflowRemoteDeploy enables you to deploy the Azure IoT Edge for Linux on Windows (EFLOW) using eflowAutoDeploy through Intune, Arc for Server channels.


## Via Intune

1. Update the `eflowRemoteDeploy.ps1` script with the required parameters in the `$jsonContent` Here string.
2. Deploy this script with the following the instructions available at [Use PowerShell scripts on Windows 10/11 devices in Intune](https://docs.microsoft.com/mem/intune/apps/intune-management-extension?msclkid=ed33bab9d07311eca7ecb4b9f790a046).

## Via Arc Enabled Servers - Custom Script Extenstion

1. Update the `eflowRemoteDeploy.ps1` script with the required parameters in the `$jsonContent` Here string.
2. Deploy this script with the following the instructions available at [Custom Script Extension for Windows](https://docs.microsoft.com/azure/virtual-machines/extensions/custom-script-windows).
