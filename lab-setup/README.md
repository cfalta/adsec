# Lab Setup Guide
## #1 Basic Lab Setup 

If you want to setup the lab on-premise (on your own laptop or in a pre-existing environment), proceed with **Option 1**. If you want to host it in Microsoft Azure, proceed with **Option 2**.

**Note:** if you want to use Azure, you need to have an existing Azure account and cover your own expenses or register a free trial. An Azure subscription is not provided in this lab.

### Option 1: On-Prem 
#### Setup virtual machines manually
Set up the following three VMs using a hypervisor of your choice.

| Hostname        | OS          | User  | Password |	Specs
| ------------- |-------------| -----|-----|-----|
|ADSEC-DC|	Windows Server 2019	|Administrator|	P@ssw0rd123!!!|	At least 2 Cores, 4 GB RAM
|ADSEC-00	|Windows Server 2019|	Administrator|	P@ssw0rd123!| At least 2 Cores, 4 GB RAM
|ADSEC-01|	Windows Server 2019|	Administrator|	P@ssw0rd123! |At least 2 Cores, 4 GB RAM

Put them all in the same subnet (using an IP range of your choice) and make sure that you have working network connection between the hosts (ping). 

Configure the following steps **on every VM**:

- Point the DNS server to the IP of ADSEC-DC
- Disable Windows Firewall (run in Powershell with admin rights)
   - `Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False`
- Disable Windows Defender
   - `Uninstall-WindowsFeature -Name Windows-Defender`

#### Promote domain controller

- Download the content of the [domain-setup-scripts](../lab-setup/domain-setup-scripts) folder to ADSEC-DC.
- Execute the [create-domain.ps1](../lab-setup/domain-setup-scripts/create-domain.ps1) script on ADSEC-DC. This will make ADSEC-DC the new domain controller of the "contoso.com" domain (shortname = "contoso"). 
- Reboot ADSEC-DC after setup is done.

Make sure that you can open "DNS Manager" as well as "Active Directory Users and Computers" without any errors popping up.

#### Join member server

Join ADSEC-00 and ADSEC-01 to the domain.

Afterwards proceed with `#2 Prepare domain`

### Option 2: Microsoft Azure

Go through the terraform instructions in this repository [activedirectory-lab](https://github.com/cfalta/activedirectory-lab).

After all VMs are up and running, make sure to disable Windows Defender on **all VMs** by running:

```
Uninstall-WindowsFeature -Name Windows-Defender
```

Afterwards proceed with `#2 Prepare domain`

## #2 Prepare domain

Download [domainprepare.ps1](../lab-setup/domain-setup-scripts/domainprepare.ps1) and [domainprepare.json](../lab-setup/domain-setup-scripts/domainprepare.json) to ADSEC-DC and make sure to save them to the same folder. `cd` into that folder and execute [domainprepare.ps1](../lab-setup/domain-setup-scripts/domainprepare.ps1).

```
cd <whatever-directory-you-choose>
cat -raw .\domainprepare.ps1 | iex
```

This script will populate AD with users, groups and OUs for the exercise.

## #3 Prepare member server

- Add the domain user "john" to the local "Administrators" group on ADSEC-00. Try to login with John at least once to make sure that authentication works as expected.
- Add the domain user "blee" to the local "Administrators" group on ADSEC-01. Try to login with Bruce Lee at least once to make sure that authentication works as expected.

| Display Name        | samAccountName | Password |	
| ------------- |-------------| -----|
|John Doe|john|P@ssw0rd|
|Bruce Lee|blee|TekkenIsAwesome!|

## #4 Prepare attacker vm

In this scenario, we assume that the user "john" and his client ADSEC-00 have been already compromised by the attacker. Please prepare ADSEC-00 as described below:

1.	Download the [attacker-tools zip files](../exercises/attacker-tools) and extract the tools to `C:\attacker-tools` on ADSEC-00 (Note: the password is "infected"). 
2.	Install dependencies: The attacker-tools.zip contains a script called `install-choco-and-dependencies.ps1`. Just run this with admin privileges and it will install python, neo4j and Firefox via the chocolatey package manager
   ```
   cat -raw .\install-choco-and-dependencies.ps1 | iex
   ```
3. Configure neo4j community edition (we’ll need this later for Bloodhound)
   - After successful installation, open Firefox and navigate to the neo4j web interface at [http://127.0.0.1:7474/browser/](http://127.0.0.1:7474/browser/). 
   - Log in with the default credentials (neo4j/neo4j) and choose a new password for the neo4j user. This step is mandatory, otherwise we can't use Bloodhound later on so make sure that you remember the password.
4. Set up impacket (we'll need this later for NTLM relay). Open an administrative shell and run

   ```
   pip install pyreadline
   pip install impacket
   ```
5. You may also want to install a text editor of your choice.