<!--
   samplefwlink:  https://aka.ms/WinIoTSamples
--->

# Azure EFLOW Samples

This repo contains samples to help customers get started with Azure IoT Edge for Linux on Windows (EFLOW). Many of these samples demonstrate end-to-end scenarios such as detecting defects on a manufacturing line, as well samples that focus on specific features such as TPM passthrough. Serveral samples demonstrate interoperatibility between Windows 10 and the EFLOW Linux VM. For more information on EFLOW, please visit the [EFLOW documentation](https://docs.microsoft.com/en-us/windows/iot/iot-enterprise/azure-iot-edge-for-linux-on-windows).

## Prerequisites

1. Some samples require Visual Studio and the Windows Software Development Kit (SDK) for Windows 10. A free copy of Visual Studio Community Edition with support for building Universal Windows Platform apps can be found on [Windows Dev Center](http://go.microsoft.com/fwlink/p/?LinkID=280676)
2. Additionally, to stay on top of the latest updates to Windows and the development tools, become a Windows Insider by joining the [Windows Insider Program](https://insider.windows.com/) (optional).

> **Note:** If you are unfamiliar with Git and GitHub, you can download the entire collection as a 
> [ZIP file](https://github.com/Microsoft/Windows-universal-samples/archive/master.zip), but be 
> sure to unzip everything to access shared dependencies. For more info on working with the ZIP file, 
> the samples collection, and GitHub, see [Get the UWP samples from GitHub](https://aka.ms/ovu2uq). 
> For more samples, see the [Samples portal](https://aka.ms/winsamples) on the Windows Dev Center. 


## End-to-End Samples
First party samples that illustrate end-to-end scenarios, focusing on Edge AI.
|Sample           | Name           | Description      |  
|----------------|----------------|------------------|  
|![image](https://user-images.githubusercontent.com/7762651/209262814-5a7d777a-44cd-41ab-af2d-902de311f110.png)| [Welding Defect Detection](./edge-ai-welding-demo/) | Edge AI & Industrial IoT sample demonstrating computer vision, AI weld porosity inferencing and OPC UA messaging using a Windows host OS, edge modules running inside the EFLOW VM, and a Grafana dashboard. |
|![image](https://user-images.githubusercontent.com/7762651/209262954-d4d90b7d-5be2-491d-967c-10248f30497b.png)| [Inventory Management for IoT Connected Coolers Solution Accelerator](https://github.com/microsoft/Inventory-Management-for-IoT-Connected-Coolers-Solution-Accelerator) | This solution accelerator shows you how to develop an inventory management solution. IoT and AI powered solution that tracks inventory at remote locations, uploads this data to Azure, and applies machine learning based forecasting models to predict restocking needs. This data on future needs can be used in a variety of ways, including scheduling delivery trucks (or other resources) more efficiently. |
|![image](https://user-images.githubusercontent.com/7762651/209263426-abc65f40-4c65-4006-861f-46781b79d5db.png)|  [Vision on Edge](https://github.com/Azure-Samples/azure-intelligent-edge-patterns/tree/master/factory-ai-vision) | <p> VoE is an open source sample illustrating how to create an end-to-end AI/ML inferencing solution. VoE ties together technologies such as: OpenCV, Onyxruntime, TensorRT for NVIDIA GPUs, OpenVINO, Custom Vision, and more. [This tutorial](https://aka.ms/AzEFLOW-VoE) walks you through how to deploy the VoE IoT Edge modules to your EFLOW device.
|![image](https://user-images.githubusercontent.com/7762651/209267209-3f5e0f01-9f14-4f23-913b-8e690b12640e.png)| [Fruit Classification using Windows + Linux Interop](./interop-customvision-textmsg-uwpapp) | <p>Two more advanced interop samples which demonstrate bidirectional communication between a Windows application and an Edge module running inside the EFLOW VM. </p><ul><li>Text messaging between a UWP application and an Edge module. </li><li>A *Custom vision* machine learning interop sample with a fruit classifier which uses a Windows UWP app to send camera frames to an Edge module for identification.</li></ul>|


#### Third-Party Samples
|Sample           | Name           | Description      |  
|-----------------|----------------|------------------| 
|![image](https://user-images.githubusercontent.com/7762651/209264369-65efc8b4-232f-46ea-a74e-fd3ebb923abe.png)|  [Industrial Safety and Impeller Defect Detection](https://github.com/scalers-ai/factorysolutions) | Created by [Scalers AI](https://www.scalers.ai/), this sample uses Intel iGPU-accelerated computer vision for anomaly detection in a manufacturing environment.  For more information and links to the video guide visit [this blog post](https://techcommunity.microsoft.com/t5/internet-of-things-blog/simplify-and-accelerate-development-and-deployment-of-computer/ba-p/3546418).
| ![image](https://user-images.githubusercontent.com/7762651/209265250-340dba76-71e9-4f29-b280-5b780ad05cbe.png)| [AI-based Worker Safety Solution](https://github.com/scalers-ai/factorysolutions)|  Also developed by [Scalers AI](https://www.scalers.ai/), this sample demonstrates an AI-based worker safety solution that can monitor potentially dangerous areas of industrial settings and shut down or suspend the operation of nearby machinery if a person is detected in that area. Details are available in this [blog post](https://techcommunity.microsoft.com/t5/internet-of-things-blog/simplify-and-accelerate-development-and-deployment-of-computer/ba-p/3546418).
|![image](https://user-images.githubusercontent.com/7762651/209265571-bd603dcd-a34a-4de6-9741-a929fce70afc.png) | [Smart Port Edge Solution Accelerator](connect.ais.arrow.com/EFLOW) | Optimizing truck turnaround times and port crane operations is a key part addressing [supply chain bottlenecks impacting our daily lives](https://community.intel.com/t5/Blogs/Tech-Innovation/Edge-5G/Fast-Tracking-Port-Modernization-Efforts-to-Address-Supply-Chain/post/1381512). This sample demonstrates how to use EFLOW with Intel iGPU and OpenVINO for license plate detection + OCR for safe and efficient port operations. For more information and access to this sample reach out to Arrow by visiting [connect.ais.arrow.com/EFLOW](connect.ais.arrow.com/EFLOW).
|![image](https://user-images.githubusercontent.com/7762651/209271475-ce524336-3575-4081-a0ee-bfbf5c76a312.png)| [Intel EFLOW Reference Implementations](https://www.intel.com/content/www/us/en/developer/articles/technical/deploy-reference-implementation-to-azure-iot-eflow.html) | <p> [Intel](https://community.intel.com/t5/Blogs/Tech-Innovation/Artificial-Intelligence-AI/Witness-the-power-of-Intel-iGPU-with-Azure-IoT-Edge-for-Linux-on/post/1382405) has created a series of reference implementations highlighting EFLOW + OpenVINO, including </p> <ul><li>Intelligent Traffic Management </li><li>Social Distancing Detection</li><li>Automated Checkout</li></ul>|

## Other EFLOW Samples
#### Interop

_:warning: **WARNING**: Enabling a communication channel between the Windows host and the EFLOW VM may increase security risks._

| Name           | Description      |  
|----------------|------------------|  
| [interop-textmsg-consoleapp](./interop-textmsg-consoleapp) | Basic interop sample demonstrating text messaging between a Windows console app and an Edge module running inside the EFLOW VM. | 

<br/>

#### Hardware Access


_:warning: **WARNING**: Enabling serial or camera passthrough may increase security risks._


| Name           | Description      |  
|----------------|------------------|  
| [serial-passthrough](./serial) | <p>Sample to configure the EFLOW VM and host to redirect communications to a serial port over the network. </li></ul>|  
| [camera-passthrough](./camera-over-rtsp) | <p>Sample to configure the EFLOW VM and host to redirect video camera feeds over the network using RTSP. </li></ul>|  

<br/>

#### GPU/VPU Acceleration

_:warning: **WARNING**: Enabling GPU/VPU passthrough may increase security risks._


| Name           | Description      |  
|----------------|------------------|  
| [Intel GPU Acceleration](https://cdrdv2.intel.com/v1/dl/getContent/648435) | <p> This guide outlines how to enable and deploy GPU-accelerated OpenVINO-based inferencing solution on EFLOW. More information about Intel's GPU support for EFLOW and Windows IoT can be found in Intel's [BKC (Best Known Configuration) Document](https://cdrdv2.intel.com/v1/dl/getContent/648433) (may require registering for Intel's development portal).</li></ul>| 

<br/>

#### Networking Access

| Name           | Description      |  
|----------------|------------------|  
| [multiple-nics](https://aka.ms/AzEFLOW-MultipleNICs) | <p>Sample to configure the EFLOW VM with multiple NICs.</li></ul>| 
| [dmz-configuration](https://aka.ms/AzEFLOW-IIoT-MultipleNIC) | <p>Sample to demonstrate how to configure Azure IoT Edge for Linux on Windows for an Industrial IoT scenario using a DMZ configuration</li></ul>|
| [routing](./networking/routing) | <p>Sample to configure the EFLOW VM network routing - Configure routes and setting up a service.</li></ul>|

<br/>

#### TPM Read-Only Passthrough

_:warning: **WARNING**:  Enabling TPM passthrough to the virtual machine may increase security risks._


| Name           | Description      |  
|----------------|------------------|  
| [Read-Only TPM](https://aka.ms/AzEFLOW-TPM-Sample) | <p> This is a sample modified from the [TSS.MSR](https://github.com/microsoft/TSS.MSR) libraries to enable reading from the TPM NV Memory via the TPM2 linux access broker. The following sample allows the underlying EFLOW VM to read from a previously initialized and written NV index.  </li></ul>|  

<br/>

## Using the samples

The easiest way to use these samples without using Git is to download the zip file containing the current version (using the following link or by clicking the "Download ZIP" button on the repo page). You can then unzip the entire archive and use the samples in Visual Studio.

   **Notes:** 
   * Before you unzip the archive, right-click it, select **Properties**, and then select **Unblock**.
   * Be sure to unzip the entire archive, and not just individual samples. The samples all depend on the SharedContent folder in the archive.   
   * In Visual Studio, the platform target defaults to ARM, so be sure to change that to x64 or x86 if you want to test on a non-ARM device. 
   
The samples use Linked files in Visual Studio to reduce duplication of common files, including sample template files and image assets. These common files are stored in the SharedContent folder at the root of the repository and are referred to in the project files using links.

**Reminder:** If you unzip individual samples, they will not build due to references to other portions of the ZIP file that were not unzipped. You must unzip the entire archive if you intend to build the samples.

For more info about the programming models, platforms, languages, and APIs demonstrated in these samples, please refer to the guidance, tutorials, and reference topics provided in the Windows 10 documentation available in the [Windows Developer Center](http://go.microsoft.com/fwlink/p/?LinkID=532421). These samples are provided as-is in order to indicate or demonstrate the functionality of the programming models and feature APIs for Windows and EFLOW.

<br/>

## Contributing
These samples are direct from the feature teams and we welcome your input on issues and suggestions for new samples. If you would like to see new coverage or have feedback, please consider contributing. You can edit the existing content, add new content, or simply create new issues. We’ll take a look at your suggestions and will work together to incorporate them into the docs.

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

> **Note**:
> When contributing, make sure you are contributing from the **develop** branch and not the master branch. Your contribution will not be accepted if your PR is coming from the master branch. 

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.
