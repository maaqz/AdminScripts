#Variables 
$vaultName = "VAULTNAME"
$secretNameAdmin = "SECRETNAMEADMIN"
$usernameAdmin = "ADMINUSERNAME"
$passwordAdmin = Get-Secret -Vault $vaultname -Name $secretNameAdmin
$secretNameSMTP = 'noreply'
$vaultpassword = (Import-CliXml ~/temp1.xml).Password #should be replaced by Azure KeyVault 
Unlock-SecretStore -Password $vaultpassword
$psCredentialAdmin = New-Object System.Management.Automation.PSCredential ($usernameAdmin, $passwordAdmin)
$passwordSMTP = Get-Secret -Vault $vaultName -Name $secretNameSMTP -AsPlainText
$ReportTarget = "Path\To\Target"
$date = Get-Date -Format "dd-MM-yyyy"

#Splatted Servername & Creds
$foo = @{
    Computername = 'SERVERNAME'
    Credential   = $psCredentialAdmin
}
#Reads the available space on the disks C, E, F, G, H, I, J and rounds the output to 2 decimals floating point
$Output = Invoke-Command -Scriptblock { 
    $hostname = & hostname
    $result = Get-PSDrive -Name C, E, F, G, H, I, J | Select-Object Name, @{Name = "Free"; Expression = { [math]::Round($_.Free / 1GB, 2) } } 
    $BadDrives = $result | Where-Object { $_.Free -lt 10 }

    #Checks if the Output is not empty and if so the Output is null and thens formats the $Output Variable as a Table
    if ($BadDrives -ne $null)
    {
        $badDrivesList = $BadDrives.Name -join ', ' 
        $BadDrives | Format-Table -AutoSize | Out-String
        Write-Output "Laufwerk $($badDrivesList) auf $hostname hat weniger als 10GB frei"
    }
    else
    {
        Out-Null
    }
} @foo

#Mail report to Shared IT-Mailbox
if ($null -eq $Output)
{
    Out-Null
}
else
{
    $SMTPServer = 'SMTPADRESS' #smtp.office365.com
    $To = 'Target@MAILADRESS'
    $Subject = "Storage Report $date"
    $EmailFrom = 'noreply@MAILADRESS'
    [string]$Body = $Output
    $smtpUsername = "noreply@MAILADRESS"
    $securePassword = ConvertTo-SecureString -String $passwordSMTP -AsPlainText -Force
    $smtpCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, $securePassword
    
    $SMTPMessage = @{
        To         = $To
        From       = $EmailFrom
        Subject    = $Subject
        Body       = $Body
        SmtpServer = $SMTPServer
        UseSsl     = $true
        Credential = $smtpCredentials
    }
    #Sends Mail to Target Mailadress and creates report at target location
    Send-MailMessage @SMTPMessage
    $Output | Out-File -Path $ReportTarget -NoClobber
}



