Config SRV-FILE01

Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.16.50.20 -PrefixLength 24 -DefaultGateway 172.16.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.50.10
Disable-NetAdapterBinding -name "Ethernet" -componentID ms_tcpip6
Rename-Computer -NewName "SRV-FILE01" -restart

Add-Computer -DomainName "orion.local" -restart
ou 
netdom join SRV-FILE01 /domain:orion.local /userd:ORION\Administrator /passwordd:*
