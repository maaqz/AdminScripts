#CSV with Name, Givenname, Surname, asmAccountName, UserpricipalName od the desired User to onboard
$Import = Import-CSV "C:\Temp\NewADUser.csv"
#this can be copied straight from the Active-Directory Group's attribute editor
$OU = "OU=YOUGETITBYNOW,OU=MOREGROUPS,OU=MOREGROUPSS,OU=USERGROUP,OU=MASTERGROUP,DC=DOMAIN,DC=local" 
#Path to CSV-File with Userdata 
$PWList = Import-CSV  -Path "Path\To\csv" 
#Gets Random Password from a Passwordlist, should be done via SecretManagement/AzVault etc.
$Password = Get-Random $PWList.Passwords | ConvertTo-SecureString -AsPlainText -Force 
#Deletes the Password from the 
$DeleteThisPW = $Password | ConvertFrom-SecureString -AsPlainText

##############################################
# Lines to set a new csv (needs further testing)#
$updatedData = $PWList | Where-Object { $_.Passwords -ne $DeleteThisPW }

$updatedData | Export-Csv -Path "Path\to\password" -NoTypeInformation

Write-Output "password for $($Import.Vollname) lautet $Password and will be deleted from the CSV" | Out-File -Path "C:\Temp\NewPWfor$($Import.AccountName).txt" -Force
>#############################################

#Fetches the groups from a specific template user with the correct Groups for the Title and applies it to the new user
$TemplateUser = "CN=TemplateUser,OU=YOUGETITBYNOW,OU=MOREGROUPS,OU=MOREGROUPSS,OU=USERGROUP,OU=MASTERGROUP,DC=DOMAIN,DC=local"
$Groups = (Get-ADUser -Identity $TemplateUser -Properties MemberOf).MemberOf >#


#Splat to initialize the contents of the csv

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
#Created new ADUser + password
New-ADUser @Attributes
Start-Sleep -Seconds 5

#Selects the newly created User and applies all Groups from the template user
$NewUser = Get-ADUser -Filter * | Where-Object { $_.samAccountname -match $Import.AccountName }
foreach ($Group in $Groups)
{
    Add-ADGroupMember -Identity $Group -Members $NewUser
}

### needs further errorhandling and flow control in general to handle fauty outputs and stderr