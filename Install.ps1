function Install () {
    $TaskExists = Get-ScheduledTask -TaskName "Spotlight" -ErrorAction SilentlyContinue
    if ($TaskExists) {
        Write-Host "Task already exists!"
        return
    } else {
        $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy UnRestricted -windowstyle hidden -File SpotlightOnDesktop.ps1" -WorkingDirectory "$PSScriptRoot"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
        $Settings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries 
        $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
        $Task | Register-ScheduledTask -TaskName "Spotlight" 
    }
}

Install
Start-ScheduledTask -TaskName "Spotlight"