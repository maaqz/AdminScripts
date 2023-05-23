#Helper to find certain Reg-Keys/Uninstall Strings for most msi's

HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where {$_.DisplayName -match "Nextcloud*"}

HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where {$_.DisplayName -match "Nextcloud*"}
