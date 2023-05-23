$Import = Import-CSV "C:\Temp\NewADUser.csv"

$OU = "OU=Extern,OU=Montage,OU=Heuft,OU=SBSUsers,OU=Users,OU=MyBusiness,DC=DOM-HEUFT-SBS,DC=local"

$PWList = Import-CSV  -Path "C:\Users\mgross\OneDrive - HEUFT\Desktop\PSCreateADUser.txt"

$Password = Get-Random $PWList.Passwords | ConvertTo-SecureString -AsPlainText -Force 

$DeleteThisPW = $Password | ConvertFrom-SecureString -AsPlainText

#Lines to set a new csv (needs testing)
$updatedData = $PWList | Where-Object { $_.Passwords -ne $DeleteThisPW }
$updatedData | Export-Csv -Path "C:\Users\mgross\OneDrive - HEUFT\Desktop\PSCreateADUser_updated.txt" -NoTypeInformation
#############################################
Write-Output "password for $($Import.Vollname) lautet $Password and will be deleted from the CSV" | Out-File -Path "C:\Temp\NewPWfor$($Import.AccountName).txt" -Force

$MusterUser = "CN=MusterUser Montageextern,OU=Extern,OU=Montage,OU=Heuft,OU=SBSUsers,OU=Users,OU=MyBusiness,DC=DOM-HEUFT-SBS,DC=local"

$Groups = (Get-ADUser -Identity $MusterUser -Properties MemberOf).MemberOf




$Attributes = @{
    Name                  = $Import.Vollname
    GivenName             = $Import.Vorname
    Surname               = $Import.Nachname
    samAccountname        = $Import.AccountName
    UserPrincipalName     = ($Import.AccountName) + "@heuft1700.com" 
    Accountpassword       = $Password
    Path                  = $OU
    CannotChangePassword  = $true
    PasswordNeverExpires  = $true
    Enabled               = $truef
    ChangePasswordAtLogon = $false  
}

New-ADUser @Attributes
Start-Sleep -Seconds 5

$NewUser = Get-ADUser -Filter * | Where-Object { $_.samAccountname -match $Import.AccountName }

foreach ($Group in $Groups)
{
    Add-ADGroupMember -Identity $Group -Members $NewUser
}
