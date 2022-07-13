 function List-EflowUSBDevices
 {
    <#
    .DESCRIPTION
        List all of the USB devices connected to Windows that could be attached to the EFLOW virutal machine
    #>

    try
    {
        
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

        usbipd list

    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Host "Exception caught!!!"  -ForegroundColor "Red"
        Write-Host $_.Exception.Message.ToString()  -ForegroundColor "Red" 
    }
}