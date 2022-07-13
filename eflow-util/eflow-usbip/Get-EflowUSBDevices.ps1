function Get-EflowUSBDevices
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

       usbipd list

   }
   catch [Exception]
   {
       # An exception was thrown, write it out and exit
       Write-Host "Exception caught!!!"  -ForegroundColor "Red"
       Write-Host $_.Exception.Message.ToString()  -ForegroundColor "Red" 
       return
   }
}