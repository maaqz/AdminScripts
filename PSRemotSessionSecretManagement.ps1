
#Start (Import Modules)
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module Microsoft.PowerShell.SecretManagement -Confirm:$false -Scope AllUsers
Install-Module Microsoft.PowerShell.SecretStore -Confirm:$false -Scope AllUsers

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

 

### Registration (pls enter Admin Credentials in the Set-Secret)
if (!(Get-SecretVault -Name HeuftVault | Select-Object -Property IsDefault) -eq "$true") {
    Register-SecretVault -Name HeuftVault -ModuleName Microsoft.PowerShell.SecretStore
    ###### zum einlesen des PW
    Get-Credential | Export-CliXml ~/temp1.xml
    Set-Secret -Vault HeuftVault
}

#Declaration
$vaultName = "HeuftVault"
$secretName = "Admin"
$vaultpassword = (Import-CliXml ~/temp1.xml).Password
Unlock-SecretStore -Password $vaultpassword

$username = "administrator"
$password = Get-Secret -Vault $vaultname -Name $secretName
$psCredential = New-Object System.Management.Automation.PSCredential ($username, $password)

#DO's

$foo = @{
    Computername = 'DATA'
    Credential   = $psCredential
}


Enter-PSSession @foo