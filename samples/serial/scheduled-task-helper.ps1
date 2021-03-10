function Add-StartupScheduledTask
{
    param (
        [Parameter(Mandatory=$true)]
        [string] $TaskName,
        [Parameter(Mandatory=$true)]
        [string] $Execute,
        [string] $Argument
    )

    $TaskDescription = $TaskName + ' enable serial over network connection'

    # the scheduled task will run in the background when system starts
    $Principal=New-ScheduledTaskPrincipal -UserId admin -LogonType S4U -Id Author
    $Trigger=New-ScheduledTaskTrigger -AtStartup
    $Action=New-ScheduledTaskAction -Execute $Execute -Argument $Argument

    #register and start the scheduled task
    Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -TaskName $TaskName -Description $TaskDescription
    Start-ScheduledTask -TaskName $TaskName
}

function Remove-StartupScheduledTask
{
    param (
        [Parameter(Mandatory=$true)]
        [string] $TaskName
    )

    Stop-ScheduledTask -TaskName $TaskName
    Unregister-ScheduledTask -TaskName $TaskName
}