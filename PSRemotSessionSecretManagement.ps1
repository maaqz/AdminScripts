
#Start (Import Modules)
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module Microsoft.PowerShell.SecretManagement -Confirm:$false -Scope AllUsers
Install-Module Microsoft.PowerShell.SecretStore -Confirm:$false -Scope AllUsers

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

 

### Registration (pls enter DesiredSecertCreds Credentials in the Set-Secret)
if (!(Get-SecretVault -Name VaultName | Select-Object -Property IsDefault) -eq "$true") {
    Register-SecretVault -Name VaultName -ModuleName Microsoft.PowerShell.SecretStore
    ###### zum einlesen des PW
    Get-Credential | Export-CliXml ~/temp1.xml
    Set-Secret -Vault VaultName
}

#Declaration
$vaultName = "VaultName"
$secretName = "DesiredSecertCreds"
$vaultpassword = (Import-CliXml ~/temp1.xml).Password
Unlock-SecretStore -Password $vaultpassword

$username = "UserNameOfServerUser"
$password = Get-Secret -Vault $vaultname -Name $secretName
$psCredential = New-Object System.Management.Automation.PSCredential ($username, $password)

#DO's

$foo = @{
    Computername = 'ServerName'
    Credential   = $psCredential
}


Enter-PSSession @foo