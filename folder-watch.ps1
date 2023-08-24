# Konfiguration
$watchFolder = "Pfad\Zum\Geteilten\Ordner"
$smtpServer = "smtp.dein-email-provider.com"
$smtpPort = 587
$smtpUsername = "deine@email.com"
$smtpPassword = "dein-email-passwort"
$recipient = "ziel@email.com"
$subject = "Änderungen im geteilten Ordner festgestellt"
$notificationCooldown = 300  # Wartezeit in Sekunden (5 Minuten)

$lastNotificationTime = [DateTime]::MinValue

# Funktion zum Senden der E-Mail
function Send-Email {
    param (
        [string]$body
    )

    $smtpCredentials = New-Object System.Net.NetworkCredential($smtpUsername, $smtpPassword)
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = $smtpCredentials

    $mailMessage = New-Object Net.Mail.MailMessage
    $mailMessage.From = $smtpUsername
    $mailMessage.To.Add($recipient)
    $mailMessage.Subject = $subject
    $mailMessage.Body = $body

    $smtp.Send($mailMessage)
}

# Überwachung des Ordners
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchFolder
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher "Created" -Action {
    $currentTime = Get-Date
    $timeSinceLastNotification = ($currentTime - $lastNotificationTime).TotalSeconds

    if ($timeSinceLastNotification -ge $notificationCooldown) {
        $changeType = $Event.SourceEventArgs.ChangeType
        $name = $Event.SourceEventArgs.Name
        $fullPath = $Event.SourceEventArgs.FullPath
        $message = "Änderungen im Ordner $fullPath festgestellt."

        Send-Email -body $message
        $global:lastNotificationTime = $currentTime
    }
}

# Warten, bis das Skript beendet wird
try {
    while ($true) {
        Start-Sleep -Seconds 10
    }
} finally {
    Unregister-Event -SourceIdentifier FileCreated
}
