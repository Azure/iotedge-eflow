# Check for admin privilege first before proceeding...
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ensure to tun this PowerShell module in  Administrator mode!" -ForegroundColor "Red"
    return
}

Write-Host "Stopping WSSDAgent service"
Stop-Service wssdagent
Remove-Item -Force -Path "HKLM:SOFTWARE\Microsoft\WssdAgent\v0.10.8-alpha.10\CertificateInternal"
Remove-Item -Force -Path "HKLM:SOFTWARE\Microsoft\WssdAgent\v0.10.8-alpha.10\IdentityInternal"

Write-Host "Restarting WSSDAgent service"
Start-Service wssdagent
Start-Sleep 10

Remove-Item -Recurse -Force -Path "$env:UserProfile\.wssd\nodectl"

& "$env:ProgramFiles\Azure IoT Edge\nodectl.exe" security login --loginpath "$env:Programdata\wssdagent\nodelogin.yaml" --identity
Start-Sleep 15
Copy-Item -Path "$env:UserProfile\.wssd\nodectl\cloudconfig"  -Destination "$env:Programdata\azure iot edge\protected\.wssd\cloudconfig" -Force

Remove-Item -Recurse -Force -Path "$env:UserProfile\.wssd\nodectl"

try 
{
    Invoke-EflowVmCommand "ls -la"
    Write-Host "Connection to EFLOW VM successful."
}
catch [Exception]
{
    Write-Host "Error caught while invoking VM command"
    $e = $_.Exception
    Write-Host $e.Message.ToString()
}