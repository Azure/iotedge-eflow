﻿ function Remove-EflowUSBDevices
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

        Write-Host "Detaching the USB device inside the EFLOW VM"
        Invoke-EflowVmCommand "sudo usbip detach --remote=$hostIp --busid=$busId"

        Write-Host "Stopping sharing the USB device to the EFLOW VM"
        usbipd unbind --busid=$busId

    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Host "Exception caught!!!"  -ForegroundColor "Red"
        Write-Host $_.Exception.Message.ToString()  -ForegroundColor "Red" 
    }
}