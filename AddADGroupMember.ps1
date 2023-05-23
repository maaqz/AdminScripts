$GroupName = "agInternet"
$Group = Get-ADGroup $GroupName
$Members = Get-ADGroupMember -Identity $Group


foreach ($Member in $Members) {
    if ($Member.objectClass -eq "user") {
        Add-ADGroupMember -Identity "FortiGateVPN" -Members $Member.distinguishedName
    }
}
