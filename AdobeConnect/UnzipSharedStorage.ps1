 # The 'Carbon' module is required to be installed to be able to use the Test-ZipFile cmdlet
# You can install the module via the PSGallery and then it can be imported when you run the script
# Install-Module -Name 'Carbon' -AllowClobber

Import-Module 'Carbon'

# USER VARIABLES
$folder = "C:\temp\7" # Folder to scan 
$logfile = "C:\temp\unzipSharedStorage.log" # Log file location
$testing = $true # $true/$false - True will only write the logs and not run the commands

# SCRIPT START
function log($string, $color)
{
   if ($color -eq $null) {$color = "white"}
   #write-host $string -foregroundcolor $color
   "$(Get-Date) $string" | out-file -Filepath $logfile -append
}

$files = Get-ChildItem -path $folder -Recurse -File | Where-Object Extension -EQ '' | Select-Object -ExpandProperty FullName

foreach ($file in $files) {
    if (Test-ZipFile $file) {
            if ($testing) {
                log "TESTING - $file is a zip"
                log "TESTING - Renaming file to $file.zip"
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
# SCRIPT END

# Robocopy script to copy from Shared Storage back into C:\Connect\content
#$source = "D:\Content\7"
#$dest = "C:\Connect\content\7"
#robocopy $source $dest /ZB /S /XO /MT /FFT /W:5 /R:5 /xf *.tmp /xd '$RECYCLE.BIN' dfsrprivate 

