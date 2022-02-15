  <#

.SYNOPSIS
    Script to assist in rolling back after you have enabled Shared Storage feature in Adobe Connect

.DESCRIPTION
    When Shared Storage is enabled all files are converted into a compressed .zip format but without the file extensions
    This script will find all compresed files, rename them to .zip, unzip them and then remove the original .zip
    Once the files have all been unzipped it will then restore all uncompressed files back into the original content folder
    
.PARAMETER USER VARIABLES
    These parameters all need to be set manually 

    $source = Folder to scan for compressed files - This is the Shared Storage Content folder
    $dest = Folder to copy files back into after being uncompressed - This is the local cache Content folder
    $logfile = Log file location
    $robocopylog = Robocopy log file location

    $copy = $true/$false - Set to false if you only want to unzip the compressed file - "$testing = $true" will also override this value e.g. "$testing true" will not perform a copy irrelevant of the value of this variable
    $testing = $true/$false - True will only write the logs and not unzip the file and then also run Robocopy with a /L switch to perform report only.

.EXAMPLE
    This script was not designed to be ran via CLI or as a module
    Please check all USER VARIABLES are set correct and then run this script manually e.g. copy and paste into your CLI or IDE
    Run with "$testing = $true" first and observe for any errors
    
.NOTES
    Author: MikeTech93
    Twitter: https://twitter.com/MikeTech93
    LinkedIn: https://www.linkedin.com/in/mike-etherington/
    GitHub: https://github.com/MikeTech93

#>

# USER VARIABLES
$source = "C:\temp\test2\7" # Shared Storage Content Folder
$dest = "C:\temp\test1\7" # C:\Connect\Content Folder
$logfile = "C:\temp\unzipSharedStorage.log" # Log file
$robocopylog = "C:\temp\unzipSharedStorageRobocopy.log" # Robocopy Log file

$copy = $true 
$testing = $false

# LOG FUNCTION
function log($string, $color) {
    if ($color -eq $null) {$color = "white"}
    #write-host $string -foregroundcolor $color
    "$(Get-Date) $string" | out-file -Filepath $logfile -append
 }

# IMPORT Carbon MODULE FOR Test-ZipFile cmdlet
if (Get-Module -ListAvailable -Name Carbon) {
    log "Module Exists"
    Import-Module 'Carbon'
} else {
    log "Module does not exist"
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module -Name 'Carbon' -Confirm:$False -Force
    Import-Module 'Carbon'
}

 # UNZIP ALL FILES THAT ARE COMPRESSED
$files = Get-ChildItem -path $source -Recurse -File | Where-Object Extension -EQ '' | Select-Object -ExpandProperty FullName

foreach ($file in $files) {
    if (Test-ZipFile $file) {
            if ($testing) {
                log "TESTING - $file is a zip"
                log "TESTING - Renaming file to $file.zip"
                $newfile = ($file + ".zip")
                $foldername = $file -replace '.*\\'
                $destination = $newfile.Substring(0, $newfile.lastIndexOf('\'))
                log "TESTING - The file is located in the following directory $destination"
                log "TESTING - Extracting $newfile archive into $destination\$foldername"
            } else {
                log "$file is a zip"
                log "Renaming file to $file.zip"
                $newfile = ($file + ".zip")
                $foldername = $file -replace '.*\\'
                $destination = $newfile.Substring(0, $newfile.lastIndexOf('\'))
                log "The file is located in the following directory $destination"
                Rename-Item $file -NewName ($newfile)
                log "Extracting $newfile archive into $destination\$foldername"
                Expand-Archive $newfile -DestinationPath ($destination + "\" + $foldername)
                Remove-Item $newfile
            }
        } else {
            log "$file is not a zip"
    }
}

# ROBOCOPY
if ($testing) {
    log "Testing Enabled - This will override whatever value is present in $copy - run robocopy with /L"
    robocopy $source $dest /L /ZB /S /XO /MT /FFT /W:5 /R:5 /xf *.tmp /xd '$RECYCLE.BIN' dfsrprivate /tee /log+:$robocopylog
} else {
    if ($copy) {
        log "Testing not enabled and Copy is enabled so run normal Robocopy"
        robocopy $source $dest /ZB /S /XO /MT /FFT /W:5 /R:5 /xf *.tmp /xd '$RECYCLE.BIN' dfsrprivate /tee /log+:$robocopylog
    } else {
        log "Testing not enabled but Copy is also not enabled so run robocopy with /L"
        robocopy $source $dest /L /ZB /S /XO /MT /FFT /W:5 /R:5 /xf *.tmp /xd '$RECYCLE.BIN' dfsrprivate /tee /log+:$robocopylog 
    }
}  