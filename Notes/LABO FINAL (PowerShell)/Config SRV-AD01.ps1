Sur SRV-AD01

Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.16.50.10 -PrefixLength 24 -DefaultGateway 172.16.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.50.10
Disable-NetAdapterBinding -name "Ethernet" -componentID ms_tcpip6
Rename-Computer -NewName "SRV-AD01" -restart

Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools

Install-ADDSForest -DomainName "orion.local" -DomainNetbiosName "ORION" -InstallDns

New-ADOrganizationalUnit -Name "ORION-DPT" -Path "DC=orion,DC=local"

New-ADOrganizationalUnit -Name "Management" -Path "OU=ORION-DPT,DC=ORION,DC=local"

New-ADOrganizationalUnit -Name "Development" -Path "OU=ORION-DPT,DC=ORION,DC=local"

New-ADOrganizationalUnit -Name "Accounting" -Path "OU=ORION-DPT,DC=ORION,DC=local"

New-ADGroup -Name "MGMT-GRP" -GroupScope Global -GroupCategory Security -Path "OU=Management,OU=ORION-DPT,DC=orion,DC=local"

New-ADGroup -Name "DEV-GRP" -GroupScope Global -GroupCategory Security -Path "OU=Development,OU=ORION-DPT,DC=orion,DC=local"

New-ADGroup -Name "ACC-GRP" -GroupScope Global -GroupCategory Security -Path "OU=Accounting,OU=ORION-DPT,DC=orion,DC=local"

New-ADUser -Name "Sébastien Sotiaux" -SamAccountName "sso" -UserPrincipalName "sso@orion.local" -Path "OU=Development,OU=ORION-DPT,DC=orion,DC=local" -AccountPassword (Read-Host -AsSecureString "Mot de passe") -Enabled $true

Add-ADGroupMember -Identity "DEV-GRP" -Members "sso"

New-ADUser -Name "Benjamin Delaunoy" -SamAccountName "bde" -UserPrincipalName "bde@orion.local" -Path "OU=Accounting,OU=ORION-DPT,DC=orion,DC=local" -AccountPassword (Read-Host -AsSecureString "Mot de passe") -Enabled $true

Add-ADGroupMember -Identity "ACC-GRP" -Members "bde"

New-ADUser -Name "Mathis Thomas" -SamAccountName "mth" -UserPrincipalName "mth@orion.local" -Path "OU=Management,OU=ORION-DPT,DC=orion,DC=local" -AccountPassword (Read-Host -AsSecureString "Mot de passe") -Enabled $true

Add-ADGroupMember -Identity "MGMT-GRP" -Members "mth"
