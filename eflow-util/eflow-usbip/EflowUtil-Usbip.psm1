<#
Root Module including all the required modules
#>

# Check for admin privilege first before proceeding...
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ensure to tun this PowerShell module in  Administrator mode!" -ForegroundColor "Red"
    return
}

# If admin privilege, import EFLOW module
Import-Module AzureEflow

# Source all the powershell scripts for the functions
. $PSScriptRoot\EflowUtil-List-EflowUSBDevices.ps1
. $PSScriptRoot\EflowUtil-Add-EflowUSBDevices.ps1
. $PSScriptRoot\EflowUtil-Remove-EflowUSBDevices.ps1
