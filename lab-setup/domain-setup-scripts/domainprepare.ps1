if(Test-Path .\domainprepare.json)
{
    $config = cat .\domainprepare.json | convertfrom-json
    if($config)
    {
        Import-Module ActiveDirectory 

        $DomainRoot = (Get-ADDomain).distinguishedname
        $DNSRoot = (get-addomain).DNSRoot

        foreach($ou in $config.ou)
        {
            if($ou.DistinguishedName)
            {
                $oupath = $ou.DistinguishedName + ","+ $DomainRoot
            }
            else
            {
                $oupath = $DomainRoot
            }
            New-ADOrganizationalUnit -Name $ou.name -Path $oupath
        }

        foreach($user in $config.user)
        {
            $upn = $user.UserPrincipalName + "@" + $DNSRoot
            $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -force
            New-ADUser -Name $user.name -SamAccountName $user.samAccountName -DisplayName $user.DisplayName -UserPrincipalName $upn -AccountPassword $securePassword -Enabled $true -Path ($user.OU + "," + $DomainRoot) -PasswordNeverExpires $true
        }

        foreach($group in $config.GroupAdd)
        {
            if($group.ou)
            {
                $oupath = $group.ou + ","+ $DomainRoot
            }
            else
            {
                $oupath = $DomainRoot
            }
            New-ADGroup -Name $group.Name -GroupScope $group.scope -GroupCategory $group.category -Description $group.description -Path $oupath
        }

        foreach($group in $config.GroupMember)
        {
            Add-ADGroupMember -Identity $group.group -Members $group.member
        }

        foreach($e in $config.execute)
        {
            $e.cmd | iex
        }
    }
}