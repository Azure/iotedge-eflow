 function Remove-EflowUSBDevices
 {
    <#
    .DESCRIPTION
        Disconnects the USB device with <busId> to the EFLOW virutal machine

    .PARAMETER busid
        Bus-id assigned by Windows to the USB device

    .PARAMETER hostIp
        IP address of the Windows host OS
    #>

    param (

        [Parameter(Mandatory)]
        [String] $busId,

        [Parameter(Mandatory)]
        [String] $hostIp
    )

    try
    {
        if (-not ($hostIp -as [IPAddress] -as [Bool])) {
            Write-Host "Error: Invalid IP4Address $hostIp" -ForegroundColor Red
            return
        }
        
        $usbipd = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty |  Where-Object {$_.DisplayName -eq 'usbipd-win'}
        if($usbipd)
        {
             Write-Host "Ok - USBIP-Win is installed on the Windows host OS"
        }
        else
        {
              Write-Host "Error - USBIP-Win it's not installed"  -ForegroundColor "Red"
              return
        }

        [String]$eflowVersion = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty |  Where-Object {$_.DisplayName -eq 'Azure IoT Edge LTS' -or $_.DisplayName -eq 'Azure IoT Edge'}).DisplayVersion
        if ([string]::IsNullOrEmpty($eflowVersion))
        {
            Write-Host "Error - EFLOW it's no installed in the Windows host OS"  -ForegroundColor "Red"
            return
        }
        elseif([int]$eflowVersion.Split(".")[1] -eq 2 -and [int]$eflowVersion.Split(".")[2] -lt 10)
        {
            Write-Host "Error - EFLOW version $eflowVersion it's not supported"  -ForegroundColor "Red"
            return
        }
        elseif([int]$eflowVersion.Split(".")[1] -eq 1 -and [int]$eflowVersion.Split(".")[2] -lt 2207)
        {
            Write-Host "Error - EFLOW version $eflowVersion it's not supported"  -ForegroundColor "Red"
            return
        }

        Write-Host "Detaching the USB device inside the EFLOW VM"

        $portCommand = "sudo usbip port | grep $hostIp" + ":3240/$busId -B 2"
        $portResult = Invoke-EflowVmCommand "$portCommand"
        $regexMatch = [regex]::match($portResult, "Port\s*(\d*)")

        if($regexMatch.Success)
        {
            $port = $regexMatch.Groups[1].Value
            Write-Host "Ok - Device with busId=$busId attached to port=$port"
            Invoke-EflowVmCommand "sudo usbip detach -p $port"
        }
        else
        {
            Write-Host "Error - Couldn't find a device with the busId=$busId"  -ForegroundColor "Red"
            return
        }

        Write-Host "Stopping sharing the USB device to the EFLOW VM"
        usbipd unbind --busid=$busId

    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Host "Exception caught!!!"  -ForegroundColor "Red"
        Write-Host $_.Exception.Message.ToString()  -ForegroundColor "Red" 
        return
    }
}