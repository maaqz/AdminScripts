###### zum einlesen des PW
Get-Credential | Export-CliXml ~/temp1.xml 
######
$modules = Get-Module -ListAvailable Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
$modules | Import-Module

### Registration (pls enter Admin Credentials in the Set-Secret)
if (!(Get-SecretVault -Name HeuftVault | Select-Object -Property IsDefault) -eq "$true")
{
    Register-SecretVault -Name HeuftVault -ModuleName Microsoft.PowerShell.SecretStore
    Set-Secret -Vault HeuftVault
}

else 
{
    Write-Output Already installed
}

$vaultpassword = (Import-CliXml ~/temp1.xml).Password
Unlock-SecretStore $vaultpassword
#ODER#

Get-Module -ListAvailable Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

$vaultpassword = (Import-CliXml ~/temp1.xml).Password

Unlock-SecretStore -Password $vaultpassword

$credential = Get-Secret -Name 'Admin' -Vault 'HeuftVault'

Invoke-Command -ComputerName "DATA" -Credential $credential -Scriptblock { (Get-CimInstance win32_logicaldisk | foreach-object { write "$($_.caption) $([math]::round(($_.size /1gb),2)), $([math]::round(($_.FreeSpace /1gb),2)) " }) }



###Restart ApPrintService 

Get-Module -ListAvailable Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

$vaultpassword = (Import-CliXml ~/temp1.xml).Password

Unlock-SecretStore -Password $vaultpassword

$credential = Get-Secret -Name 'Admin' -Vault 'TestVault'
Invoke-Command -ComputerName "win7-apprint" -Credential $credential -Scriptblock { Restart-Service -DisplayName "APplus*" }


#Neuer Ansatz 03-23
Import-Module Microsoft.PowerShell.SecretManagement
$vaultName = "TestVault"
$secretName = "administrator"

$vaultpassword = (Import-CliXml C:\Users\%USERNAME%\temp1.xml).Password

Unlock-SecretStore -Password $vaultpassword
$credential = Get-Secret -Vault $vaultName -Name $secretName | Select-Object -ExpandProperty SecretValue
$username = $credential.UserName
$password = $credential.Password | ConvertTo-SecureString -AsPlainText -Force
$psCredential = New-Object System.Management.Automation.PSCredential ($username, $password)
$TargetServer = 'Win10Test'
Invoke-Command -ComputerName $TargetServer -Credential $Cred -Scriptblock { Get-Process }



Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module Microsoft.PowerShell.SecretManagement -Confirm:$false -Scope AllUsers
Install-Module Microsoft.PowerShell.SecretStore -Confirm:$false -Scope AllUsers

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

Get-Credential | Export-Clixml ~/tempTEST.xml
$vaultpassword = (Import-Clixml ~/tempTEST.xml).Password
Unlock-SecretStore -$vaultpassword
Set-Secret -Name Admin1 -Secret .\tempTEST.xml


Install-Module SecretManagement.LastPass
Import-Module SecretManagement.LastPass

Unregister-LastPassVault 
Connect-LastPass -Vault Shared-IT -User UserEmailAdress -Trust