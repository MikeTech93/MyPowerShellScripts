<#
.SYNOPSIS
    Script to update URL_PATH for multiple rooms which is not available via Connect Central console

.DESCRIPTION
    Enter all your new URLs in the url_updates.csv file
    The new_url column is not needed that was just there for reference purposes at time of writing
    The complete_url column is what this script will loop through
    You can set $testing to $true to use the test_url_updates.csv file instead, this way you can test with some meeting rooms that are not important
    For the script to function correctly you should use the username/password of a Connect Central Administrator account
    
    Adobe API Documentation:
        https://helpx.adobe.com/adobe-connect/webservices/login-sessions-user-handle-requests.html
        https://helpx.adobe.com/adobe-connect/webservices/update-sco-url.html

.EXAMPLE
    The script was thrown together quickly so just run this directly in your favorite IDE and watch the output
    It will break out on any major errors e.g. authentication but continue on simple errors e.g. incorrectly formatted URL - so monitor output for results
    
.NOTES
    Author: MikeTech93
    Twitter: https://twitter.com/MikeTech93
    LinkedIn: https://www.linkedin.com/in/mike-etherington/
    GitHub: https://github.com/MikeTech93
#>

### User Variables
$testing = $true
$testingPath = "./test_url_updates.csv"
$csvPath = "./url_updates.csv"
$username = "xxx"
$password = "xxx"
$connectURL = "connect.xxx.co.uk"

### Set path dependant on $testing variable
if ($testing){
    $path = $testingPath
} else {
    $path = $csvPath
}

### Check if $path exists
if (Test-Path $path){
    write-host "File Found"
} else {
    throw "CSV File not found"
}

### Generate Session Cookie
$auth = Invoke-WebRequest -Uri "https://$connectURL/api/xml?action=login&login=$username&password=$password" -SessionVariable session

### Check Session Cookie is valid
if ($auth.Content -like '*<status code="ok"/>*') {
    write-host "Authentication Successful"
} else {
    $logout = Invoke-WebRequest -Uri "https://$connectURL/api/xml?action=logout"
    throw "Authentication failed, Script Failed --- $auth.Content"
}

### Get list of URLs
$urls = Import-Csv -Path $path

### Loop through urls and update
foreach ($url in $urls){

    ### Send update-sco-url HTTP Request  
    $invoke = Invoke-WebRequest -Uri $url.complete_url -WebSession $session
    if ($invoke.Content -like '*<status code="ok"/>*') {
        write-host "$url.complete_url Updated successfully"
    } else {
        write-host "ERROR - $url.complete_url - $invoke.Content"
    }

}

### logout and empty Session Cookie
$logout = Invoke-WebRequest -Uri "https://$connectURL/api/xml?action=logout"

### Check logout was successful
if ($logout.Content -like '*<status code="ok"/>*') {
    write-host "Log out successful"
} else {
    throw "Log out unsuccesful, Script Failed --- $auth.Content"
}