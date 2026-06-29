Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.28.122 -PrefixLength 24 -DefaultGateway 10.10.28.254
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.28.121
Disable-NetAdapterBinding -name "Ethernet" -componentID ms_tcpip6
netsh advfirewall set allprofiles state off 
!activer remote desktop
!désactiver sécurité IE
slmgr /rearm
Rename-Computer -NewName " EXCHANGE-MZEPP" -restart
Add-Computer -DomainName "m.zepp.lan" -restart