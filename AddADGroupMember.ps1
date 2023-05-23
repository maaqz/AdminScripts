#Declare Security-Group to copy all members from
$SourceGroupName = "SourceGroupname" #eg. Administrator
$TargetGroupName = "TargetGroup" #eg VPN-Group

#Fetches the Security-Group's identiy by Get-ADGroupMember
$Group = Get-ADGroup $SourceGroupName
$Members = Get-ADGroupMember -Identity $Group

#Enumnerates alle Members of the SourceGroup and adds thm to the target group
foreach ($Member in $Members)
{
    if ($Member.objectClass -eq "user")
    {
        Add-ADGroupMember -Identity $TargetGroupName -Members $Member.distinguishedName
    }
}

