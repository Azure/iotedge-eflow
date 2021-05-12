function Execute-SshCommand{
    <
    .DESCRIPTION
        Executes an SSH command on the VM.

    .PARAMETER command
        Command to be executed in the VM

    .PARAMETER ignoreError
        Optionally, ignore errors from the command (don't throw).
    #>

    param (
        [String] $command,
        [Switch] $ignoreError
    )

    if ([string]::IsNullOrEmpty($command)) {
        Write-Status "Command should not be empty" -Color Red
        exit
    }


    $configurationKey = "HKLM:SOFTWARE\Microsoft\AzureIoTEdge"
    $eflowRegistry = Get-ItemProperty -Path $configurationKey

    $eflowBaseDir = $eflowRegistry.eflowBaseDir
    if ([string]::IsNullOrEmpty($eflowBaseDir)) {
        $eflowBaseDir = $([io.Path]::Combine($env:ProgramFiles, "Azure IoT Edge"))
        Write-Status "Registry entry for base directory was empty. Defaulting to '$eflowBaseDir'."
    }

    if (-Not (Get-Module -ListAvailable -Name AzureEFLOW)) {
        Write-Status "EFLOW Module Not Found"
        exit
    }

    $userName = $(Start-Job { Get-EflowVmUserName } | Receive-Job -Wait -AutoRemoveJob)
    if ([string]::IsNullOrEmpty($userName)) {
        Write-Status "EFLOW UserName Not Found"
        exit
    }

    $addrInfo = $(Start-Job { Get-EflowVmAddr } | Receive-Job -Wait -AutoRemoveJob)
    if (($addrInfo.length -ne 2) -Or [string]::IsNullOrEmpty($addrInfo[1])) {
        Write-Status "EFLOW IP Address Not Found"
        exit
    }

    $vmIp = $addrInfo[1]

    if ($null -ne $addrInfo -And $addrInfo[1] -ne "")
    {
        $sshPrivKey = $([io.Path]::Combine($eflowBaseDir, "id_rsa"))
        $sshargs = "-o LogLevel=ERROR -o ""StrictHostKeyChecking no""  -i ""${sshPrivKey}"" ${userName}@${vmIp} "
        $command = $sshargs + $linux_command
        Write-Status $("Executing SSH command: $vmCommand - IP: $vmIp")
        $output = Execute-Command -Command "ssh" -Arguments $command -ignoreError:$ignoreError.IsPresent
        Write-Status $("${output}") -Color Green
        exit
    }
    else
    {
        Write-Status "Could not resolve virtual machine IP address" -color Red
    }
}
