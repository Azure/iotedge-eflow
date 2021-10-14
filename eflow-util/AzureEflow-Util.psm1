$EflowVmUserName           = "iotedge-user"
$identityCertDirVm         = "/home/$EflowVmUserName/certs/"
$identityPkDirVm           = "/home/$EflowVmUserName/private/"

Import-Module AzureEflow

function EflowUtil-CopyEdgeCertificates
{
    <#
    .DESCRIPTION
        Populate the iotedge config.yaml file with provisioning information

    .PARAMETER rootCAPath
        Root CA source path on Windows -  Root CA it's the topmost certificate authority for the IoT Edge scenario

    .PARAMETER deviceCACertificatePath
        Device CA Certificate path on Windows

    .PARAMETER deviceCAPrivateKeyPath
        Device CA Private Key path on Windows
    #>

    param (
        [Parameter(Mandatory)]
        [String] $rootCAPath,

        [Parameter(Mandatory)]
        [String] $deviceCACertificatePath,

        [Parameter(Mandatory)]
        [String] $deviceCAPrivateKeyPath
    )

    try
    {
        if ([string]::IsNullOrEmpty($rootCAPath) -Or
            [string]::IsNullOrEmpty($deviceCACertificatePath) -Or
            [string]::IsNullOrEmpty($deviceCAPrivateKeyPath))
        {
            throw "Root CA Certificate, Device CA Certificate Path, and/or Device CA Private Key parameters not specified"
        }


        if(!(Test-Path $rootCAPath))
        {
             throw "Root CA Certificate path is not correct"
        }

        if(!(Test-Path $deviceCACertificatePath))
        {
             throw "Device CA Certificate path is not correct"
        }

        if(!(Test-Path $deviceCAPrivateKeyPath))
        {
             throw "Device CA Private Key path is not correct"
        }

        $userName = $script:EflowVmUserName

        $rootCACertFileName = Split-Path $rootCAPath -leaf
        $deviceCACertificateFileName = Split-Path $deviceCACertificatePath -leaf
        $deviceCAPrivateKeyFileName = Split-Path $deviceCAPrivateKeyPath -leaf

        $rootCACertPathVm = $script:identityCertDirVm + $rootCACertFileName
        $deviceCACertificatePathVm = $script:identityCertDirVm + $deviceCACertificateFileName
        $deviceCAPrivateKeyPathVm = $script:identityPkDirVm + $deviceCAPrivateKeyFileName
        
        Write-Host "Copying certificates  virtual machine..."
        
        Invoke-EflowVmCommand -command "sudo mkdir -p $script:identityCertDirVm; sudo chown -R ${userName}: $script:identityCertDirVm"
        Invoke-EflowVmCommand -command "sudo mkdir -p $script:identityPkDirVm; sudo chown -R ${userName}: $script:identityPkDirVm"

        Copy-EflowVmFile -fromFile "$rootCAPath" -toFile "$rootCACertPathVm" -pushFile
        Copy-EflowVmFile -fromFile "$deviceCACertificatePath" -toFile "$deviceCACertificatePathVm" -pushFile
        Invoke-EflowVmCommand -command "sudo chown -R iotedge: $script:identityCertDirVm"

        Copy-EflowVmFile -fromFile "$deviceCAPrivateKeyPath" -toFile "$deviceCAPrivateKeyPathVm" -pushFile
        Invoke-EflowVmCommand -command "sudo chown -R iotedge: $script:identityPkDirVm"

        Write-Host "Certificates copied."
        
        $insertString = ("certificates:\`n" +
        " \ device_ca_cert: \`"file://$rootCACertPathVm\`"\`n" +
        " \ device_ca_pk: \`"file://$deviceCAPrivateKeyPathVm\`"\`n" +
        " \ trusted_ca_certs: \`"file://$deviceCACertificatePathVm\`"\`n")

        
        Write-Host "Writing IoT Edge configuration..."

        Invoke-EflowVmCommand -command "sudo sed -i '/^certificates:$/,+3 s.^.#.' /etc/iotedge/config.yaml"
    
        Invoke-EflowVmCommand -command """sudo sed -i '$ a\$insertString' /etc/iotedge/config.yaml"""

        $insertStringByteCount = [System.Text.Encoding]::ASCII.GetByteCount($insertString)

        $edgeConfigFile = Invoke-EflowVmCommand -command """sudo tail -c $insertStringByteCount /etc/iotedge/config.yaml"""

        # basic sanity check whether the information was written
        if (($matchStrings | ForEach-Object {$edgeConfigFile -like "*$_*"}).Count -lt $matchStrings.Length)
        {
            throw "Failed to provision config.yaml. Please provision manually."
        }

        Invoke-EflowVmCommand -command "sudo systemctl restart iotedge"

        # Sleep a bit, otherwise iotedge service may initially be in running state and crash at startup after we query the status info
        Start-Sleep 3

        # get iotedge service status, set ignoreError switch to get actual output from the submitted command for processing
        $statusInfo = Invoke-EflowVmCommand -command "sudo systemctl status iotedge" -ignoreError

        if ((($statusInfo -like "*Loaded: loaded*").Count -ne 1) -Or (($statusInfo -like "*Active: active (running)*").Count -ne 1))
        {
            throw "iotedge service not running after certificates configuration, please investigate manually"
        }
        else
        {
            Write-Host "Certificates configuration successful. iotedge service running."
        }

        return "OK"
    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Host "Exception caught!!!"  -color "Red"
        Write-Host $_.Exception.Message.ToString()  -color "Red" 
    }
}
