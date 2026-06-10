Config SRV-FILE01

Get-NetAdapter
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.16.50.20 -PrefixLength 24 -DefaultGateway 172.16.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.50.10
Disable-NetAdapterBinding -name "Ethernet" -componentID ms_tcpip6
Rename-Computer -NewName "SRV-FILE01" -restart

Add-Computer -DomainName "orion.local" -restart
ou 
Netdom join SRV-FILE01 /domain:orion.local /userd:ORION\Administrator /passwordd:*

New-Item -Path "D:\DEPARTMENTS" -ItemType Directory #MD
New-Item -Path "D:\DEPARTMENTS\Management" -ItemType Directory
New-Item -Path "D:\DEPARTMENTS\Development" -ItemType Directory
New-Item -Path "D:\DEPARTMENTS\Accounting" -ItemType Directory
New-Item -Path "D:\DEPARTMENTS\Public" -ItemType Directory

Get-ChildItem -Path D:\DEPARTMENTS #LS

New-SmbShare -Name "DEPARTMENTS" -Path "D:\DEPARTMENTS\" -ChangeAccess "ORION\Domain Users" 
 
icacls.exe "D:\DEPARTMENTS\Management\" /inheritance:e
icacls.exe "D:\DEPARTMENTS\Management\" /inheritance:d
icacls.exe "D:\DEPARTMENTS\Management\" /grant "ORION\MGMT-GRP:(OI)(CI)M"
icacls.exe "D:\DEPARTMENTS\Management\" /grant "CREATOR OWNER:(OI)(CI)(IO)F"
icacls.exe "D:\DEPARTMENTS\Management\" /remove "Authenticated Users"
icacls.exe "D:\DEPARTMENTS\Management\" /remove "BUILTIN\Users"
icacls.exe "D:\DEPARTMENTS\Management\"

icacls.exe "D:\DEPARTMENTS\Accounting\" /inheritance:d
icacls.exe "D:\DEPARTMENTS\Accounting\" /grant "ORION\ACC-GRP:(OI)(CI)M"
icacls.exe "D:\DEPARTMENTS\Accounting\" /remove "BUILTIN\Users"
icacls.exe "D:\DEPARTMENTS\Accounting\" /grant "CREATOR OWNER:(OI)(CI)(IO)F"
icacls.exe "D:\DEPARTMENTS\Accounting\" /remove "Authenticated Users"
icacls.exe "D:\DEPARTMENTS\Accounting\"

icacls.exe "D:\DEPARTMENTS\Development\" /inheritance:d
icacls.exe "D:\DEPARTMENTS\Development\" /grant "ORION\DEV-GRP:(OI)(CI)M"
icacls.exe "D:\DEPARTMENTS\Development\" /grant "CREATOR OWNER:(OI)(CI)(IO)F"
icacls.exe "D:\DEPARTMENTS\Development\" /remove "BUILTIN\Users"
icacls.exe "D:\DEPARTMENTS\Development\" /remove "Authenticated Users"
icacls.exe "D:\DEPARTMENTS\Development\"

icacls.exe "D:\DEPARTMENTS\Public\" /inheritance:d
icacls.exe "D:\DEPARTMENTS\Public\" /grant "ORION\Domain users:(OI)(CI)M"
icacls.exe "D:\DEPARTMENTS\Public\" /grant "CREATOR OWNER:(OI)(CI)(IO)F"
icacls.exe "D:\DEPARTMENTS\Public\" /remove "BUILTIN\Users"
icacls.exe "D:\DEPARTMENTS\Public\" /remove "Authenticated Users"
icacls.exe "D:\DEPARTMENTS\Public\"

#Création DFS NameSpace

Install-WindowsFeature FS-DFS-NameSpace -IncludeManagementTools
New-Item -Path D:\DFSROOT\
New-Item -Path "D:\DFSROOT\share$" -ItemType Directory
New-SmbShare -name "Share$" -Path 'D:\DFSRoot\share$\' -FullAccess "Orion\Domain Admins" -ChangeAccess "Orion\DOmain Users"
New-DfsnRoot -Path "\\orion.local\shares" -TargetPath "\\SRV-FILE01\Share$" -Type DomainV2

New-DfsnFolder -Path "\\orion.local\shares\Public" -TargetPath "\\SRV-FILE01\DEPARTMENTS\Public"
New-DfsnFolder -Path "\\orion.local\shares\Management" -TargetPath "\\SRV-FILE01\DEPARTMENTS\Management"
New-DfsnFolder -Path "\\orion.local\shares\Accounting" -TargetPath "\\SRV-FILE01\DEPARTMENTS\Accounting"
New-DfsnFolder -Path "\\orion.local\shares\Development" -TargetPath "\\SRV-FILE01\DEPARTMENTS\Development"

New-GPO -Name "Gpo"

New-GPO -Name "GPO_User_Restrictions"
New-GPLink -Name "GPO_User_Restrictions" -Target "OU=ORION-DPT,DC=orion,DC=local"
 
Set-GPRegistryValue -Name "GPO_User_Restrictions" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
 
Set-GPRegistryValue -Name "GPO_User_Restrictions" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallpaper" -Type DWord -Value 1