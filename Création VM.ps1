cd c:\VM\LABOPS
md VRDSH
cd VRDSH
New-VHD -Path .\VRDSH-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "VRDSH" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\VRDSH-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName VRDSH -DynamicMemoryEnabled $false
Set-VMProcessor -VMName VRDSH -Count 2

cd c:\VM\LABOPS
md VRDCB
cd VRDCB
New-VHD -Path .\VRDCB-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "VRDCB" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\VRDCB-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName VRDCB -DynamicMemoryEnabled $false
Set-VMProcessor -VMName VRDCB -Count 2

cd c:\VM\LABOPS
md VRDWA
cd VRDWA
New-VHD -Path .\VRDWA-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "VRDWA" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\VRDWA-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName VRDWA -DynamicMemoryEnabled $false
Set-VMProcessor -VMName VRDWA -Count 2