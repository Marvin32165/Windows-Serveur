Sur SRV-AD01

Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.10 -PrefixLength 24 -DefaultGateway 192.168.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.10
Disable-NetAdapterBinding -name "Ethernet" -componentID ms_tcpip6
Rename-Computer -NewName "DC" -restart

Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools

Install-ADDSForest -DomainName "
" -DomainNetbiosName "CONTOSO" -InstallDns

New-ADOrganizationalUnit -Name "CONTOSO-DPT" -Path "DC=contoso,DC=com"

New-ADOrganizationalUnit -Name "ingenieurs" -Path "OU=CONTOSO-DPT,DC=contoso,DC=com"

New-ADOrganizationalUnit -Name "comptables" -Path "OU=CONTOSO-DPT,DC=contoso,DC=com"

New-ADGroup -Name "Grp-ingenieur" -GroupScope Global -GroupCategory Security -Path "OU=ingenieurs,OU=CONTOSO-DPT,DC=CONTOSO,DC=com"

New-ADGroup -Name "Grp-comptabilite" -GroupScope Global -GroupCategory Security -Path "OU=comptables,OU=CONTOSO-DPT,DC=CONTOSO,DC=com"

New-ADUser -Name "ingenieur1" -SamAccountName "ig1" -UserPrincipalName "ingenieur1@contoso.com" -Path "OU=ingenieurs,OU=CONTOSO-DPT,DC=CONTOSO,DC=com" -AccountPassword (Read-Host -AsSecureString "Mot de passe") -Enabled $true

Add-ADGroupMember -Identity "Grp-ingenieur" -Members "ig1"

New-ADUser -Name "comptable1" -SamAccountName "ct1" -UserPrincipalName "comptable1@contoso.com" -Path "OU=comptables,OU=CONTOSO-DPT,DC=CONTOSO,DC=com" -AccountPassword (Read-Host -AsSecureString "Mot de passe") -Enabled $true

Add-ADGroupMember -Identity "Grp-comptabilite" -Members "ct1"