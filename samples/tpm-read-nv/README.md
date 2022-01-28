# TPM - Read from NV Memory

## Introduction
This sample allows the EFLOW VM to read from the TPM Nonvolatile memory storage. This sample is derived from the [TSS.MSR Samples](https://github.com/microsoft/TSS.MSR).

_**Note**: The EFLOW VM only allows read operations from the TPM. The NV index must be previously initialized and written to from the Windows Host in order to read from the EFLOW VM._



## Prerequisites
As a prerequisite, ensure that the NV index (default index=3001) is initialized and has 8 bytes of data written to it. The AuthValue used by default by the sample is {1,2,3,4,5,6,7,8} which corresponds to the NV (Windows) Sample in the TSS.MSR libaries when writing to the TPM. All index initialization must take place on the Windows Host before reading from the EFLOW VM.


## Instructions
- Step 1 - Install EFLOW on the Windows Host
- [Step 2 - Provision the EFLOW VM with the TPM](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-provision-devices-at-scale-linux-on-windows-tpm?view=iotedge-2018-06&tabs=physical-tpm%2Cpowershell)
-  Step 3 - Initialize the TPM index from the Windows Host
-   Step 4 - Build the Sample for the EFLOW VM
-   [Step 5 - Push Sample to the EFLOW VM](https://docs.microsoft.com/en-us/azure/iot-edge/reference-iot-edge-for-linux-on-windows-functions?view=iotedge-2018-06#copy-eflowvmfile)
-   Step 6 - Run the Sample using the _DeviceLinux_ option

## Feedback
If you have problems with this sample, please post an issue in this repository.
