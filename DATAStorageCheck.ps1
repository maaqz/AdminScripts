#Variables 
$vaultName = "HeuftVault"
$secretNameAdmin = "Admin"
$usernameAdmin = "administrator"
$passwordAdmin = Get-Secret -Vault $vaultname -Name $secretNameAdmin
$secretNameSMTP = 'noreply'
$vaultpassword = (Import-CliXml ~/temp1.xml).Password
Unlock-SecretStore -Password $vaultpassword
$psCredentialAdmin = New-Object System.Management.Automation.PSCredential ($usernameAdmin, $passwordAdmin)
$passwordSMTP = Get-Secret -Vault $vaultName -Name $secretNameSMTP -AsPlainText
$date = Get-Date -Format "dd-MM-yyyy"

#Splatted Servername & Creds
$foo = @{
    Computername = 'DATA'
    Credential   = $psCredentialAdmin
}
#Reads the available space on the disks
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
    $SMTPServer = 'smtp.office365.com'
    $To = 'it@heuft-backofenbau.de'
    $Subject = "DATA Storage Report $date"
    $EmailFrom = 'noreply@heuft1700.com'
    [string]$Body = $Output
    $smtpUsername = "noreply@heuft1700.com"
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
    #Do's
    Send-MailMessage @SMTPMessage
    $Output | Out-File -Path "C:\Temp\DataReport$date.txt" -Append 
}



