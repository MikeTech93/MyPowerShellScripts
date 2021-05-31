<#
.SYNOPSIS
    Short description of script

.DESCRIPTION
    Long description of script
    
.PARAMETER Paramater1
    Short description of what Parameter1 does 

.PARAMETER Paramater2
    Short description of what Parameter2 does 

.PARAMETER Paramater3
    Short description of what Parameter3 does 

.EXAMPLE
    Example of how to run the code e.g.

    PS C:\> Get-ChildItem 'P:\test\*.jpg' | Set-ImageSize -Paramater1 "p:\test2" -Paramater2 300 -Parameter3 375 -Verbose
    VERBOSE: Image 'P:\test\00001.jpg' was resized from 236x295 to 300x375 and saved in 'p:\test2\00001.jpg'
    VERBOSE: Image 'P:\test\00002.jpg' was resized from 236x295 to 300x375 and saved in 'p:\test2\00002.jpg'
    VERBOSE: Image 'P:\test\00003.jpg' was resized from 236x295 to 300x375 and saved in 'p:\test2\00003.jpg'
    
.NOTES
    Author: MikeTech93
    Twitter: https://twitter.com/MikeTech93
    LinkedIn: https://www.linkedin.com/in/mike-etherington/
    GitHub: https://github.com/MikeTech93
#>

Write-host "START SCRIPT HERE"