Config SRV-AD02

Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress 172.16.50.11 -PrefixLength 24 -DefaultGateway 172.16.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 172.16.50.10
Disable-NetAdapterBinding -name "Ethernet 2" -componentID ms_tcpip6
Rename-Computer -NewName "SRV-AD02" -restart

Add-Computer -DomainName "orion.local" -restart

Install-WindowsFeature ad-domain-services,DNS -IncludeManagementTools



Pour ajouter en controleur AD par IFM

SUR SRV-AD01

cd c:\
md IFM
cd IFM
ntdsutil "activate instance ntds" ifm "create sysvol full C:\IFM" quit quit

robocopy c:\IFM \\SRV-AD02\C$\IFM /E

SUR SRV-AD02

Install-ADDSDomainController -DomainName "orion.local" -InstallationMediaPath "C:\IFM" -InstallDns