<#
.SYNOPSIS
    Script to compltely empty cache on AzureDevOps Build Server
.DESCRIPTION
    Azure DevOps maintenance jobs can be ran to clear down cache however,
    if you have builds that run 24/7 then it is not possible to use maintenance jobs due to 1 being the lowest value which you can set for "Days to keep unused working directories"
    
.PARAMETER Paramater1
    Short description of what Parameter1 does 
.PARAMETER Paramater2
    Short description of what Parameter2 does 
.PARAMETER Paramater3
    Short description of what Parameter3 does 
.EXAMPLE
    Script is designed to be ran as a schedeuled job
    Ensure to set user variables manually first
    
.NOTES
    Author: MikeTech93
    Twitter: https://twitter.com/MikeTech93
    LinkedIn: https://www.linkedin.com/in/mike-etherington/
    GitHub: https://github.com/MikeTech93
#>

## Find Windows Service
$adoService = Get-Service  | Where-Object {$_.DisplayName -like "Azure Pipelines Agent*" -or $_Name -like "VSTS Agent*" -or $_Name -like "vstsagent*"}

if ($adoService) {
    Write-Host "Azure DevOps service found"
} else {
    Write-Host "No service found, exiting script"
    exit
}

## Checks for running jobs - https://stackoverflow.com/questions/47290467/get-if-tfs-build-agent-is-busy-or-not ???

# Log location = D:\agent\_diag | Example end of file = [2022-02-21 11:57:49Z INFO Worker] Job completed. | Example log name = Worker_20220221-130241-utc.log

# if no running jobs stops azure devops processes

## rename _work to _work_old

## starts processes

## Checks if _work gets recreated (I'm not sure if this automatically gets recreated or need to initiate a job to recreate, need to do some testing)

## delete _work_old folder