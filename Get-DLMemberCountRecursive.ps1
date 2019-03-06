# This script can be used to get the member count of 
# distribution lists when you have nested distribution 
# list membership.  The script will only count the members
# of groups with the proxy address attribute set.  This is
# an indicator that the group is either a distribution 
# group or a mail enabled security group.  Output is to a
# CSV file in the current directory.

Function Get-ADGroupCount ($Group)
{
    $GroupMemberCount = 0

    Foreach ($GroupMember in $Group.Member)
    {
        $ADObject = Get-ADObject $GroupMember

        If ($ADObject.ObjectClass -eq 'group')
        {
            $ADGroup = Get-ADGroup $ADObject -Properties member
            $GroupMemberCount += $(Get-ADGroupCount $ADGroup)
        }
        Else
        {
            $GroupMemberCount += 1
        }
    }

    Return $GroupMemberCount
}

$Log = '.\Distribution List Member Count.csv'
$DistributionGroups = Get-ADGroup -Filter "Name -like '*'" -Properties proxyAddresses,member

Foreach ($DistributionGroup in $DistributionGroups)
{
    If ($DistributionGroup.proxyAddresses)
    {
        $MemberCount = Get-ADGroupCount $DistributionGroup
        Add-Content -Path $Log -Value "$($DistributionGroup.Name),$MemberCount"
    }
}
