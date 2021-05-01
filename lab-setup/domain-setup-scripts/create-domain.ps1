
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath 'C:\Windows\NTDS' -DomainMode 'Win2012' -DomainName 'contoso.com' -DomainNetbiosName 'contoso' -ForestMode 'Win2012' -InstallDns:$true -LogPath 'C:\Windows\NTDS' -NoRebootOnCompletion:$true -SysvolPath 'C:\Windows\SYSVOL' -SafeModeAdministratorPassword (Convertto-SecureString -AsPlainText "P@ssw0rd123!" -Force) -Force:$true


