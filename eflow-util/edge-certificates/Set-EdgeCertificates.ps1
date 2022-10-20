function Set-EflowVmEdgeCertificates
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
    .PARAMETER identityCertDirVm
        Certificates folder path on CBL-Mariner
    .PARAMETER identityPkDirVm
        Private Key folder path on CBL-Mariner
    #>

    param (
        [Parameter(Mandatory)]
        [String] $rootCAPath,

        [Parameter(Mandatory)]
        [String] $deviceCACertificatePath,

        [Parameter(Mandatory)]
        [String] $deviceCAPrivateKeyPath,

        [String] $identityCertDirVm,
        [String] $identityPkDirVm
    )

    try
    {
        $EflowVmUserName = "iotedge-user"

        if ([string]::IsNullOrEmpty($rootCAPath) -Or
            [string]::IsNullOrEmpty($deviceCACertificatePath) -Or
            [string]::IsNullOrEmpty($deviceCAPrivateKeyPath))
        {
            throw "Root CA Certificate, Device CA Certificate Path, and/or Device CA Private Key parameters not specified"
        }

        if([string]::IsNullOrEmpty($identityCertDirVm))
        {
            $identityCertDirVm = "/home/$EflowVmUserName/certs/"
            Write-Host "identityCertDirVm is empy - Using default: $identityCertDirVm"
        }
        
        if([string]::IsNullOrEmpty($identityPkDirVm))
        {
            $identityPkDirVm = "/home/$EflowVmUserName/private/"
            Write-Host "identityPkDirVm is empy - Using default: $identityPkDirVm"
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

        $rootCACertPathVm = $identityCertDirVm + $rootCACertFileName
        $deviceCACertificatePathVm = $identityCertDirVm + $deviceCACertificateFileName
        $deviceCAPrivateKeyPathVm = $identityPkDirVm + $deviceCAPrivateKeyFileName
        
        Write-Host "Copying certificates  virtual machine..."
        
        Invoke-EflowVmCommand -command "sudo mkdir -p $identityCertDirVm; sudo chown -R ${userName}: $identityCertDirVm"
        Invoke-EflowVmCommand -command "sudo mkdir -p $identityPkDirVm; sudo chown -R ${userName}: $identityPkDirVm"

        Copy-EflowVmFile -fromFile "$rootCAPath" -toFile "$rootCACertPathVm" -pushFile
        Copy-EflowVmFile -fromFile "$deviceCACertificatePath" -toFile "$deviceCACertificatePathVm" -pushFile
        Invoke-EflowVmCommand -command "sudo chown -R iotedge: $identityCertDirVm"

        Copy-EflowVmFile -fromFile "$deviceCAPrivateKeyPath" -toFile "$deviceCAPrivateKeyPathVm" -pushFile
        Invoke-EflowVmCommand -command "sudo chown -R iotedge: $identityPkDirVm"

        Write-Host "Certificates copied."
        
        $insertString = ("certificates:\`n" +
        " \ device_ca_cert: \`"file://$rootCACertPathVm\`"\`n" +
        " \ device_ca_pk: \`"file://$deviceCAPrivateKeyPathVm\`"\`n" +
        " \ trusted_ca_certs: \`"file://$deviceCACertificatePathVm\`"\`n")

        # Check IoT Edge version (1.1 or 1.2)
        $iotEdgeVersion = Invoke-EflowVmCommand "sudo iotedge version"
        
        if([string]::IsNullOrEmpty($iotEdgeVersion))
        {
            Write-Host "Could not retrieve IoT Edge version"  -ForegroundColor "Red"
            return
        }
    
        # By default, command is for IoT Edge 1.1 using config.yaml file and service is iotedge
        $edgeConfigurationFile = '/etc/iotedge/config.yaml'
        $iotedgeService = "iotedge"

        # If IoT Edge = 1.2/1.3/1.4 check for config.toml file and service is aziot-edged
        if($iotEdgeVersion -Match "1.2" -Or $iotEdgeVersion -Match "1.3" -Or $iotEdgeVersion -Match "1.4")
        {
            $edgeConfigurationFile = '/etc/aziot/config.toml'
            $iotedgeService = "aziot-edged"
        }
    
        Write-Host "Writing IoT Edge configuration..."
        
        Invoke-EflowVmCommand -command "sudo sed -i '/^certificates:$/,+3 s.^.#.' $edgeConfigurationFile"

        Invoke-EflowVmCommand -command """sudo sed -i '$ a\$insertString' $edgeConfigurationFile"""

        $insertStringByteCount = [System.Text.Encoding]::ASCII.GetByteCount($insertString)

        $edgeConfigFile = Invoke-EflowVmCommand -command """sudo tail -c $insertStringByteCount $edgeConfigurationFile"""

        # basic sanity check whether the information was written
        if (($matchStrings | ForEach-Object {$edgeConfigFile -like "*$_*"}).Count -lt $matchStrings.Length)
        {
            throw "Failed to provision config.yaml. Please provision manually."
        }

        Invoke-EflowVmCommand -command "sudo systemctl restart $iotedgeService"

        # Sleep a bit, otherwise iotedge service may initially be in running state and crash at startup after we query the status info
        Start-Sleep 3

        # get iotedge service status, set ignoreError switch to get actual output from the submitted command for processing
        $statusInfo = Invoke-EflowVmCommand -command "sudo systemctl status $iotedgeService" -ignoreError

        if ((($statusInfo -like "*Loaded: loaded*").Count -ne 1) -Or (($statusInfo -like "*Active: active (running)*").Count -ne 1))
        {
            throw "$iotedgeService service not running after certificates configuration, please investigate manually"
        }
        else
        {
            Write-Host "Certificates configuration successful. $iotedgeService service running."
        }

        return "OK"
    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Host "Exception caught!!!"  -ForegroundColor "Red"
        Write-Host $_.Exception.Message.ToString()  -ForegroundColor "Red" 
    }
} 