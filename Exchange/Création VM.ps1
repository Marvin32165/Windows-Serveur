Création Client win11 

cd c:\VM\LABOPS
md CLIENT-WIN11-EXCHANGE
cd CLIENT-WIN11-EXCHANGE
New-VHD -Path .\CLIENT-WIN11-EXCHANGE-DISK1.vhdx -SizeBytes 127GB -Dynamic
New-VM -Name "CLIENT-WIN11-EXCHANGE" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\CLIENT-WIN11-EXCHANGE-DISK1.vhdx -Path .\ -SwitchName "Wan"
Set-VMMemory -VMName CLIENT-WIN11-EXCHANGE -DynamicMemoryEnabled $false
Set-VMProcessor -VMName CLIENT-WIN11-EXCHANGE -Count 2
Add-VMDvdDrive -VMName CLIENT-WIN11-EXCHANGE -Path "C:\Users\s_13950_admin\Desktop\ISO\Windows 11\Win11_25H2_English_x64_v2.iso"
Set-VMFirmware -VMName CLIENT-WIN11-EXCHANGE -FirstBootDevice (Get-VMDvdDrive -VMname CLIENT-WIN11-EXCHANGE)
Set-VMKeyProtector -VMName CLIENT-WIN11-EXCHANGE -NewLocalKeyProtector; Enable-VMTPM -VMName CLIENT-WIN11-EXCHANGE

AD 1

cd c:\VM\LABOPS
md ADDS-M.ZEPP
cd ADDS-M.ZEPP
New-VHD -Path .\ADDS-M.ZEPP-DISK1.vhdx -SizeBytes 50GB -Dynamic
New-VM -Name "ADDS-M.ZEPP" -Generation 2 -MemoryStartupBytes 8GB -VHDPath .\ADDS-M.ZEPP-DISK1.vhdx -Path .\ -SwitchName "Exchange"
Set-VMMemory -VMName ADDS-M.ZEPP -DynamicMemoryEnabled $false
Set-VMProcessor -VMName ADDS-M.ZEPP -Count 2
Add-VMDvdDrive -VMName ADDS-M.ZEPP -Path "C:\Users\s_13950_admin\Desktop\ISO\Windows serveur\fr-fr_windows_server_2022_updated_may_2026_x64_dvd_c4723e47.iso"
Set-VMFirmware -VMName ADDS-M.ZEPP -FirstBootDevice (Get-VMDvdDrive -VMname ADDS-M.ZEPP)

AD 2

cd c:\VM\LABOPS
md EXCHANGE-M.ZEPP
cd EXCHANGE-M.ZEPP
New-VHD -Path .\EXCHANGE-M.ZEPP-DISK1.vhdx -SizeBytes 200GB -Dynamic
New-VM -Name "EXCHANGE-M.ZEPP" -Generation 2 -MemoryStartupBytes 16GB -VHDPath .\EXCHANGE-M.ZEPP-DISK1.vhdx -Path .\ -SwitchName "Exchange"
Set-VMMemory -VMName EXCHANGE-M.ZEPP -DynamicMemoryEnabled $false
Set-VMProcessor -VMName EXCHANGE-M.ZEPP -Count 2
Add-VMDvdDrive -VMName EXCHANGE-M.ZEPP -Path "C:\Users\s_13950_admin\Desktop\ISO\Windows serveur\fr-fr_windows_server_2022_updated_may_2026_x64_dvd_c4723e47.iso"
Set-VMFirmware -VMName EXCHANGE-M.ZEPP -FirstBootDevice (Get-VMDvdDrive -VMname EXCHANGE-M.ZEPP)