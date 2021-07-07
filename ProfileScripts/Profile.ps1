Function Connect-Msol {
    $UserCredential = Get-Credential -Message "Enter your Office 365 admin credentials (full email address)"
    Connect-MsolService -Credential $UserCredential
    $msolconnected = $true
	$host.ui.RawUI.WindowTitle = "MSOL Connected - "
}
	
Function Connect-365Partner ($domain) {
    if (!$domain) { $a = read-host "Enter the partners domain name" } else { $a = $domain }
    $LiveCred = Get-Credential -Message "Enter your Office 365 admin credentials (full email address)"
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/PowerShell-LiveID?DelegatedOrg=$a.onmicrosoft.com -Credential $LiveCred -Authentication Basic –AllowRedirection
    Import-PSSession $Session
    $host.ui.RawUI.WindowTitle = "365 Connected - " + $a
}

	Function Connect-365 {
	$LiveCred = Get-Credential
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
	Import-PSSession $Session
	$host.ui.RawUI.WindowTitle = "365 Connected"
}

        Function Connect-Compliance {
        $LiveCred = Get-Credential
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
        Import-PSSession $Session -DisableNameChecking
    }

Function Connect-SharePoint ($orgName) {
	if (!$orgName) { $a = read-host "Enter the Office 365 Tenant name e.g. mygroup" } else { $a = $orgName }
    $userCredential = Get-Credential -Message "Enter your Office 365 SharePoint admin credentials (full email address)"
    Connect-SPOService -Url https://$a-admin.sharepoint.com -Credential $userCredential
	$host.ui.RawUI.WindowTitle = "Sharepoint Connected - " + $a
}
	
Function Get-Clients {
    if ($msolconnected -ne $true) {Connect-Msol}
    Get-MsolPartnerContract -All  | select Name, DefaultDomainNAme
}

cls
write-host "
Custom functions:
       Connect-Msol
          Connect to Partner Azure Active Directory
       Get-Clients
          List all Office365 Partners
       Connect-365Partner -domain
          Connect to specific Office365 Partner (parameter is optional)
       Connect-365
          Connect into Office 365 ECP using global admin credentials
       Connect-SharePoint
          Connect to specific Office365 SharePoint
" -ForegroundColor Green