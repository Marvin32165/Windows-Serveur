cd c:\VM\LABOPS
md DC
cd DC
New-VHD -Path .\DC-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "DC" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\DC-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName DC -DynamicMemoryEnabled $false
Set-VMProcessor -VMName DC -Count 2

cd c:\VM\LABOPS
md RDSH1
cd RDSH1
New-VHD -Path .\RDSH1-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "RDSH1" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\RDSH1-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName RDSH1 -DynamicMemoryEnabled $false
Set-VMProcessor -VMName RDSH1 -Count 2

cd c:\VM\LABOPS
md RDSH2 
cd RDSH2 
New-VHD -Path .\RDSH2-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "RDSH2" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\RDSH2-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName RDSH2 -DynamicMemoryEnabled $false
Set-VMProcessor -VMName RDSH2 -Count 2

cd c:\VM\LABOPS
md RDCB 
cd RDCB 
New-VHD -Path .\RDCB-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "RDCB" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\RDCB-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName RDCB -DynamicMemoryEnabled $false
Set-VMProcessor -VMName RDCB -Count 2

cd c:\VM\LABOPS
md RDWA 
cd RDWA 
New-VHD -Path .\RDWA-DISK1-DIFF.vhdx -ParentPath "C:\PARENT\TEST-SYSPREP.vhdx" -Differencing
New-VM -Name "RDWA" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\RDWA-DISK1-DIFF.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName RDWA  -DynamicMemoryEnabled $false
Set-VMProcessor -VMName RDWA  -Count 2

cd c:\VM\LABOPS
md CLIENT 
cd CLIENT 
New-VHD -Path .\CLIENT-DISK1.vhdx -SizeBytes 127GB -Dynamic 
New-VM -Name "CLIENT" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\CLIENT-DISK1.vhdx -Path .\ -SwitchName "LABOPS"
Set-VMMemory -VMName CLIENT  -DynamicMemoryEnabled $false
Set-VMProcessor -VMName CLIENT  -Count 2
Add-VMDvdDrive -VMName CLIENT  -Path "C:\Users\s_13950_admin\Desktop\ISO\Windows 11\Win11_25H2_English_x64_v2.iso"
Set-VMFirmware -VMName CLIENT  -FirstBootDevice (Get-VMDvdDrive -VMname CLIENT )
Set-VMKeyProtector -VMName CLIENT  -NewLocalKeyProtector; Enable-VMTPM -VMName CLIENT 

