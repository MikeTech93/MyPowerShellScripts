## Custom script to send emails based on users expiration date in Active Directory
## This script was designed to prevent users passwords expiring and then having to contact the help desk to get their passwords reset


# START OF USER VARIABLES
$smtpServer="xxx" # Enter SMTP Server here
$expireindays = 5
$from = "From Name <address@company.com>" # Enter FROM address here
$logging = "Enabled" # Set to Disabled to Disable Logging
$logFile = "c:\Windows\Logs\Password_change_notification\logs.csv"

# Test before deploying into live system 
$testing = "Enabled" # Set to Disabled to Email Users
$testRecipient = "address@companyname.com" # Enter email to send test to if $testing is enabled

$date = Get-Date -format ddMMyyyy

# !! You will also need to read/amend the Email Body section below !!

# END OF USER VARIABLES

# Check Logging Settings
if (($logging) -eq "Enabled")
{
# Test Log File Path
$logfilePath = (Test-Path $logFile)
if (($logFilePath) -ne "True")
{
    # Create CSV File and Headers
    New-Item $logfile -ItemType File
    Add-Content $logfile "Date,Name,EmailAddress,DaystoExpire,ExpiresOn"
}
}   # End Logging Check

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
$Name = (Get-ADUser $user | foreach { $_.Name})
$emailaddress = $user.emailaddress
$passwordSetDate = (get-aduser $user -properties * | foreach { $_.PasswordLastSet })
$PasswordPol = (Get-AduserResultantPasswordPolicy $user)
# Check for Fine Grained Password
if (($PasswordPol) -ne $null)
{
    $maxPasswordAge = ($PasswordPol).MaxPasswordAge
}

$expireson = $passwordsetdate + $maxPasswordAge
$today = (get-date)
$daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
    
# Set Greeting based on Number of Days to Expiry.

# Check Number of Days to Expiry
$messageDays = $daystoexpire

if (($messageDays) -ge "1")
{
    $messageDays = "in " + "$daystoexpire" + " days"
}
else
{
    $messageDays = "today"
}

# Email Subject Set Here
$subject="Your password will expire $messageDays"

# Email Body sent to users
$body ="
    <p>&nbsp;</p>
    <p>Dear $name,</p>
    <p><strong>Your Password will expire $messageDays</strong></p>
    <p>The exact time and date that your password will expire on is: <strong>$expireson</strong></p>
    <p><strong>If you are</strong> on a PC or Laptop <strong>in the office</strong> please follow these instructions: <br /><em>The requirements of your new password are as follows: 8 Digits long with a minimum of 1 capital letter, 1 numeric value and 1 standard character</em></p>
    <ol>
    <li>Press CTRL + ALT + DELETE</li>
    <li>Select Change a password...</li>
    <li>Type your old password and your new password into the presented box's</li>
    </ol>
    <p><strong>If you are</strong> on a PC or Laptop <strong>Outside of the office</strong>&nbsp;please follow the above instructions when inside the office.</p>
    <p><strong>If you are&nbsp;</strong>on a PC or Laptop<strong> Outside of the office and will not be in the office $messageDays </strong> then please follow these instructions:</p>
    <ol>
    <li><a href=mailto:address@companyname.com?Subject=Extend%20Email%20Password>Email Company Support</a></li>
    </ol>
    <p><strong>OR</strong></p>
    <ol>
    <li>Phone Company on: +44xxx</li>
    <li>Ask for password to be extended</li>
    </ol>
    <p><strong>If you have your e-mails on your phone</strong> and/or any other mobile device then please remember you will also have to update the password there after you have change it.</p>
    <p>If you are having difficulties with any of this then please do not hesitate to contact Company</p>
    <p><a href=mailto:address@companyname.com?Subject=Password%20Issues%20>Company Support</a><br /><strong>OR</strong><br />+44xxx</p>
    <p>Kind Regards,</p>
    <p>Company Support</p>
"
# Email Body sent to admins
    $body2 ="
<font face=Calibri><font color=black><font size=4> 
<p>Attached to this email is the daily password notification report.<br /><br />The report is also located at: $logfile on ServerName</p>
"
# If Testing Is Enabled - Email Administrator
if (($testing) -eq "Enabled")
{
    $emailaddress = $testRecipient
} # End Testing

# If a user has no email address listed
if (($emailaddress) -eq $null)
{
    $emailaddress = $testRecipient    
}# End No Valid Email

# Send Email Message
if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
{
     # If Logging is Enabled Log Details
    if (($logging) -eq "Enabled")
    {
        Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson" 
    }
    # Send Email Message
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High  

} # End Send Message

} # End User Processing

if (($logging) -eq "Enabled")
    {
Send-Mailmessage -smtpServer $smtpServer -from $from -to $testRecipient -subject "Daily Password Report" -body $body2 -bodyasHTML -priority High  -attachments $logfile 
    }

# End