Config VRDWA

Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.16.50.30 -PrefixLength 24 -DefaultGateway 172.16.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.50.10
Disable-NetAdapterBinding -name "Ethernet" -componentID ms_tcpip6
Rename-Computer -NewName "VRDSH" -restart

Add-Computer -DomainName "orion.local" -restart