# Exercise 1 - Reconnaissance

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

PowerView: [https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1)

## Exercise

We’ll use PowerView in this lab exercise. Make sure to load it into your Powershell session like this before you start. 

```
cd C:\attacker-tools
cat -raw ".\PowerView.ps1" | iex
```

Get basic domain info

```
Get-Domain
Get-DomainController
```

Get all domain computer; Note: usually you would use a filter since this gives you a ton of results in a real domain environment. 
```
Get-DomainComputer
```

Get all domain computer but display only name,dnsname and creation date and format as a table
```
Get-DomainComputer | select samaccountname,dnshostname,whencreated | Format-Table
```

Get all domain user
```
Get-DomainUser
```

Get all user who are a member of the domain admins group
```
Get-DomainUser | ? {$_.memberof -like "*Domain Admins*"}
```

Get all user who are a member of the domain admins group, but show only the name
```
Get-DomainUser | ? {$_.memberof -like "*Domain Admins*"} | select samaccountname
```

Get all custom groups, assuming that all groups which are not stored at the default locations are custom (obviously error prone but mostly effective)
```
Get-DomainGroup | ? { $_.distinguishedname -notlike "*CN=Users*" -and $_.distinguishedname -notlike "*CN=Builtin*"} | select samaccountname,description
```

## Questions

- How many computers are in the domain and what OS are they running on?
- How many user objects are in the domain? Write a powershell query to list all user in table form showing only the attributes samaccountname, displayname, description and last password change.
- Can you identify any custom admin groups? Change the powershell query above in a generic way so it only returns custom admin groups.
- Who is a member of the custom admin group you found and when was his password last set?
- Think of simple ways to identify service accounts in the domain? Write a powershell query that lists all service accounts based on the pattern you came up with.
