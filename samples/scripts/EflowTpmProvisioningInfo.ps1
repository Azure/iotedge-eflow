  function Get-EflowVmTpmProvisioningInfo
{
    <#
    .DESCRIPTION
        Get the TPM provisioning info
    #>

    try
    {
        Write-Status "Retrieving TPM EK pub hash and registration ID for automated provisioning with DPS"

        $isFeatureEnabled = Get-EflowVmFeature -feature "DpsTpm"
        if (-not $isFeatureEnabled)
        {
            Write-SubStatus "TPM provisioning was not enabled! Please enable TPM using the command: Set-EflowVmFeature -feature 'DpsTpm' -enable" -color "Green"
            return $null
        }

        $allStats = $null
        [int] $sleepDuration = 1
        [int] $totalRetryCount = 30
        for ($num = 1 ; $num -le $totalRetryCount ; $num++)
        {
            $command = "[ ! -f /tmp/tpm_device_provision.txt ] && echo '\n' | sudo /usr/bin/tpm_device_provision > /tmp/tpm_device_provision.txt; eflTmpVarTPMEK=(`$(awk 'f{print;f=0} /Endorsement Key:/{f=1}' /tmp/tpm_device_provision.txt)); eflTmpVarTPMRI=(`$(awk 'f{print;f=0} /Registration Id:/{f=1}' /tmp/tpm_device_provision.txt)); echo `$eflTmpVarTPMEK `$eflTmpVarTPMRI"

            $allStats = Invoke-EflowVmCommand -command $command

            if ($allStats.Count -eq 2)
            {
                break
            }

            Write-SubStatus "Retrying to retrieve TPM information..."

            $command = "sudo rm -f /tmp/tpm_device_provision.txt"

            Invoke-EflowVmCommand -command $command

            Start-Sleep $sleepDuration
        }

        if ($allStats.Count -ne 2)
        {
            Write-SubStatus "TPM provisioning information not available!" -color "Green"
            return $null;
        }
        else
        {
            Write-SubStatus "TPM provisioning information retrieved!" -color "Green"
            return $allStats;
        }
    }
    catch [Exception]
    {
        # An exception was thrown, write it out and exit
        Write-Status -msg "Exception caught!!!"
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-SubStatus -msg "$msg at line $line" -color "Red"
    }
}

function Write-Status
{
    <#
    .DESCRIPTION
        Outputs to the console with a prefix for readability. Expected to be used for status text.

    .PARAMETER msg
        The message to output

    .PARAMETER color
        The color to use for the output
    #>

    param (
        [String]$msg,
        [String]$color = "Yellow"
    )

    if ($msg)
    {
        $time = Get-Date -DisplayHint Time
        Write-Host "`n[$time] " -ForegroundColor Gray -NoNewline
        Write-Host "$msg`n" -ForegroundColor $color
    }
}

function Write-SubStatus
{
    <#
    .DESCRIPTION
        Outputs to the console with a prefix for readability. Expected to be used for sub-status text.

    .PARAMETER msg
        The message to output

    .PARAMETER color
        The color to use for the output

    .PARAMETER indentChar
        Char to use as the bulletpoint of the status message

    .PARAMETER timestamp
        Optionally, output a timestamp with the message
    #>

    param (
        [String]$msg,
        [String]$color = "White",
        [String]$indentChar = "-",
        [Switch]$timestamp
    )

    if ($msg)
    {
        if ($timestamp.IsPresent)
        {
            $indentChar += $(" [" + (Get-Date -DisplayHint Time) + "]")
        }

        Write-Host " $indentChar $msg" -ForegroundColor $color
    }
}
