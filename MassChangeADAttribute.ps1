Import-Module ActiveDirectory
# Declaration
$OU = "OU=Insert,OU=Object,OU=Here,OU=MyBusiness,DC=DOM-INSERT-HERE,DC=local"

$attribute = "INSERTATTRIBUTENAME" 

$newValue = "INSERTVALUE"

$users = Get-ADUser -SearchBase $OU -Filter *

# Change declared attribute for all affected ADUser in the variable $users
foreach ($user in $users) {

Set-ADUser -Identity $user.DistinguishedName -Replace @{$attribute = $newValue}

Write-Host "Attribute $attribute from $($user.Name) changed to $newValue"
}

Write-Host "Attribute $attribute changed for all Users in $OU successfully