<#
  Sample script to deploy eflow via Intune
#>
# Here string for the json content
$jsonContent = @'
{
    "schemaVersion":"1.0",
    "version":"1.0",
    "eflowProduct" : "Azure IoT Edge LTS",
    "enduser":{
        "acceptEula" : "Yes",
        "acceptOptionalTelemetry" : "Yes"
    },
    "eflowProvisioning":{
        "provisioningType" : "ManualConnectionString",
        "devConnString" : ""
    }
}
'@
$exitCode = 0
#Download the AutoDeploy script
$deploytime = Get-Date -Format "yyMMdd-HHmm"
$transcriptFile = "$PSScriptRoot\eadlog-$deploytime.txt"
Start-Transcript -Path $transcriptFile

Set-ExecutionPolicy Bypass -Scope Process -Force
$scriptFile = "$PSScriptRoot\AutoDeploy.ps1"
$jsonFile = "$PSScriptRoot\userconfig.json"
Out-File -FilePath $jsonFile -InputObject $jsonContent -Force
$url = 'https://raw.githubusercontent.com/Azure/iotedge-eflow/main/eflowautodeploy/eflowAutoDeploy.ps1'
if (Test-Path $scriptFile) {
    Remove-Item $scriptFile -Force | Out-Null
}
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $url -OutFile $scriptFile
$ProgressPreference = 'Continue'
# dot source the script
. $scriptFile 
# invoke the workflow
$retval = Start-EadWorkflow $jsonFile
# report error via Write-Error for Intune to show proper status
if ($retval) {
    Write-Host "Deployment Successful"
} else {
    Write-Error -Message "Deployment failed" -Category OperationStopped
    $exitCode = -1
}
Stop-Transcript | Out-Null
exit $exitCode