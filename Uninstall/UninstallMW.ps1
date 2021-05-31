## Custom script to uninstall Managed Workplace, Avast Antivirus and any other features they may have installed
## This script was designed because the uninstall tools provided by Managed Workplace never fully removed all features that it installed


## CREATE delete_reg_key FUNCTION
function delete_reg_key([string]$key)
{
    if ( Test-Path $key )
    {
        Remove-Item -Path "$key" -Recurse;
        log "The Key [$key] is deleted.";       
    }
    else
    {
       log "The Key [$key] does not exist.";
    }   
}

## CREATE log FUNCTION
$logfile = "C:\Windows\Logs\MWUninstall.txt" ## ENTER LOG FILE LOCATION HERE

function log($string, $color)
{
if ($color -eq $null) {$color = "white"}
#write-host $string -foregroundcolor $color
"$(Get-Date) $string" | out-file -Filepath $logfile -append
}

## UNINSTALL PREMIUM REMOTE CONTROL
$executables = "C:\Program Files (x86)\Avast\Premium Remote Agent\unins001.exe","C:\Program Files\Avast\Premium Remote Agent\unins001.exe","C:\Program Files (x86)\Avast\Premium Remote Control\unins001.exe","C:\Program Files\Avast\Premium Remote Control\unins001.exe","C:\Program Files (x86)\Avast\Premium Remote Agent\unins000.exe","C:\Program Files\Avast\Premium Remote Agent\unins000.exe","C:\Program Files (x86)\Avast\Premium Remote Control\unins000.exe","C:\Program Files\Avast\Premium Remote Control\unins000.exe"
$a = 0
foreach ($exe in $executables) {
If (Test-Path $exe)
{
log ($exe + " Found")
Start-Process -FilePath $exe -ArgumentList "/SILENT" -Wait -NoNewWindow
log ($exe + " Removed")
} else {
log ($exe + " Not Found")
$a += 1
}
}

## REMOVE PREMIUM REMOTE CONTROL FOLDERS
If ($a = $executables.count) {
log ("No uninstall executables found")
$folders = "C:\Program Files (x86)\Avast\Premium Remote Agent","C:\Program Files (x86)\Avast\Premium Remote Control","C:\Program Files\Avast\Premium Remote Agent","C:\Program Files\Avast\Premium Remote Control"
foreach ($folder in $folders) {
if (Test-Path $folder) {
    Remove-Item $folder -Recurse -ErrorAction SilentlyContinue
    log ($folder + " Removed")
    }
}
log ("All Premium Remote Control folders have been removed")
}

## REMOVE DESKTOPINFO
delete_reg_key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DesktopInfo"

$folders = "C:\DesktopInfo"
foreach ($folder in $folders) {
if (Test-Path $folder) {
Remove-Item $folder -Recurse -ErrorAction SilentlyContinue
log ($folder + " Removed")
}
}
log ("All Desktop Info folders have been removed")

## REMOVE SCHEDULED TASK PATCH MESSAGE

If (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue) {

log "Get-ScheduledTask exists - now checking for task"

$taskName = “Schedule_Task_Patch_Message”
$task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName } | Select-Object -First 1

if ($null -ne $task) {
$task | Unregister-ScheduledTask -Confirm:$false
log “$taskName Removed” -ForegroundColor Yellow
} else {
log "$taskName Not Found"
}

} else {
log "Get-ScheduledTask does not exist - Unable to check for task"
}

$folders = "C:\Company_Messages"
foreach ($folder in $folders) {
if (Test-Path $folder) {
Remove-Item $folder -Recurse -ErrorAction SilentlyContinue
log ($folder + " Removed")
}
}
log ("All Scheduled Task Patch Message folders have been removed")

## REMOVE DEVICE MANAGER & WORKPLACE SUPPORT ASSISTANT

$pkeys = "{4F5697AE-6613-4A2E-A14D-26829334E9F4}","{B21A24B5-8E95-4D9D-A634-48040D44462F}","{08139C86-6342-4652-BA5D-AAF86F05C5B8}","{465716EE-1C14-470E-A61D-2E634AFC869E}","{2D3D7217-28BA-4393-A7E9-8A478DC9470D}","{58B87E46-9466-424C-9EC7-6613F6B62B65}"

foreach ($pkey in $pkeys) {

if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$pkey") {
    log "$pkey is present - Attempting removal"

    $MSIUninstallArguments = @(
    "/x"
    "$pkey"
    "/QN"
    )
Start-Process "msiexec.exe" -ArgumentList $MSIUninstallArguments -Wait -NoNewWindow
} else {
log "$pkey key does not exist "
}
}