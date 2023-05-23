#Start (Import Modules)
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module Microsoft.PowerShell.SecretManagement -Confirm:$false -Scope AllUsers
Install-Module Microsoft.PowerShell.SecretStore -Confirm:$false -Scope AllUsers

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

 

### Registration (pls enter SECRETNAME Credentials in the Set-Secret)
if (!(Get-SecretVault -Name VAULTNAME | Select-Object -Property IsDefault) -eq "$true") {
    Register-SecretVault -Name VAULTNAME -ModuleName Microsoft.PowerShell.SecretStore #registers SecretVault
    Get-Credential | Export-CliXml ~/temp1.xml # to read in password of the vault as a encrypted xml -> Azure KeyVault or Hashicorp Vault is best practice here
    Set-Secret -Vault VAULTNAME #sets the desired secret
}

#Declaration to unlock the Vault
$vaultName = "VAULTNAME"
$secretName = "SECRETNAME"
$vaultpassword = (Import-CliXml ~/temp1.xml).Password
Unlock-SecretStore -Password $vaultpassword

$username = "SECRETNAME"
$password = Get-Secret -Vault $vaultname -Name $secretName
$psCredential = New-Object System.Management.Automation.PSCredential ($username, $password)

#Invoke-Command -ComputerName "SERVERNAME" -Credential $pscredential -Scriptblock {Get-Service -DisplayName "APplus*"} -AsJob
Invoke-Command -ComputerName "SERVERNAME" -Credential $pscredential -Scriptblock {Receive-Job -Id 1,2,3,4,5,6,7 -Keep}
