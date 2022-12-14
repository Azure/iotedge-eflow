# Text Messaging & Custom Vision Interop Samples
## Progress

- [x] [Introduction](../README.md)  
- [x] [Step 1 - Setup Azure Resources](./Setup%20Azure%20Resources.MD)
- [x] [Step 2 - Setup Azure IoT Edge for Linux on Windows](./Setup%20Azure%20IoT%20Edge%20for%20Linux%20on%20Windows.MD)  
- [x] [Step 3 - Develop and publish the IoT Edge Linux module](./Develop%20and%20publish%20the%20IoT%20edge%20Linux%20module.MD)  
- [ ] **Step 4 - Create Certificates for Authentication**  
- [ ] [Step 5 - Develop the Windows C# UWP Application](./Develop%20the%20Windows%20C%23%20UWP%20Application.MD)
- [ ] [Step 6 - Configuring the IoT Edge Device](./Configuring%20the%20IoT%20Edge%20Device.MD)  
- [ ] [Step 7 - Run samples](./Run%20samples.MD)   
- [ ] [Troubleshooting](./Troubleshooting.MD) 
---
# Step 4: Create Certificates for Authentication
This part describes the relevant steps to create sample certificates for the authentication between downstream device and IoT edge.

* **To create a sample PKI with certificate validity for one month**  
 Complete the steps within the steps of [Create demo certificates to test IoT Edge device features](https://learn.microsoft.com/en-us/azure/iot-edge/how-to-create-transparent-gateway?view=iotedge-1.4&tabs=eflow#create-demo-certificates).  

* **To generate customizable test certificates**  
Follow the steps described in [Generate test certificates for Edge Gateway](https://github.com/Azure-Samples/IoTEdgeAndMlSample/tree/master/CreateCertificates) to create sample certificates to use for the interop solution. It generates certificates with default subject name "turbofanGateway" and 30 days validity. To extend the validity of certificates (or) to change the subject name, make the following modifications to **dockerfile** then re-build the docker image.

You can also use your own root CA certificate in case you have a (test) PKI for downstream devices and edge devices. In any of the two latter cases, replace the private key, certificate chain, and root CA cert.

Go to [Next Step](./Develop%20the%20Windows%20C%23%20UWP%20Application.MD)  
