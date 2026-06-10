New-VMSwitch -name "LABOPS" -SwitchType Private

cd c:\
cd VM
md LABOPS
cd LABOPS
md SRV-AD01
cd SRV-AD01
New-VHD -Path .\SRV-AD01-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "SRV-AD01" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\SRV-AD01-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"

Set-VMMemory -VMName SRV-AD01 -DynamicMemoryEnabled $false
Set-VMProcessor -VMName SRV-AD01 -Count 2

|

cd c:\VM\LABOPS
md SRV-AD02
cd SRV-AD02
New-VHD -Path .\SRV-AD02-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "SRV-AD02" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\SRV-AD02-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName SRV-AD02 -DynamicMemoryEnabled $false
Set-VMProcessor -VMName SRV-AD02 -Count 2

|

cd c:\VM\LABOPS
md SRV-FILE01
cd SRV-FILE01
New-VHD -Path .\SRV-FILE01-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "SRV-FILE01" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\SRV-FILE01-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName SRV-FILE01 -DynamicMemoryEnabled $false
Set-VMProcessor -VMName SRV-FILE01 -Count 2

|

Client

cd c:\VM\LABOPS
md CLIENT-WIN11
cd CLIENT-WIN11
New-VHD -Path .\CLIENT-WIN11-DISK1.vhdx -SizeBytes 127GB -Dynamic 0
New-VM -Name "CLIENT-WIN11" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\CLIENT-WIN11-DISK1.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName CLIENT-WIN11 -DynamicMemoryEnabled $false
Set-VMProcessor -VMName CLIENT-WIN11 -Count 2
Add-VMDvdDrive -VMName CLIENT-WIN11 -Path "C:\Users\s_13950_admin\Desktop\ISO\Windows 11\Win11_25H2_English_x64_v2.iso"
Set-VMFirmware -VMName CLIENT-WIN11 -FirstBootDevice (Get-VMDvdDrive -VMname CLIENT-WIN11)
Set-VMKeyProtector -VMName CLIENT-WIN11 -NewLocalKeyProtector; Enable-VMTPM -VMName CLIENT-WIN11