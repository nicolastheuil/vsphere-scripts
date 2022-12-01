# Variables
$VIServer = "X.X.X.X
$VIUsername = "administrator@vsphere.local"
$VIPassword = "VMware1!"
# last x days to collect
$statsdays = 30
# metrics interval (minutes) 
$statsinterval = 30

#Import VMware modulde
#Get-Module -Name VMware* -ListAvailable | Import-Module
 
#Connect to vCenter Server using credentials
Write-Host "Connection to vCenter Server " -ForegroundColor Gray -NoNewLine
Write-Host $VIServer -ForegroundColor Blue

try {
	Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -ErrorAction Stop | Out-Null
}
catch [Exception]{
	$exception = $_.Exception
	Write-Host "Erreur lors de la connection : " $exception.InnerException.message -ForegroundColor Red
	Break
}

Write-Host "Connected to" $VIServer -ForegroundColor Green 
 
$allvms = @()
Write-Host "Getting VMs from inventory ... " -ForegroundColor Gray -NoNewLine
$vms = Get-VM | Select Name, @{N="Cluster";E={Get-Cluster -VM $_}}, VMHost, PowerState, NumCpu, MemoryGB, UsedSpaceGB, ProvisionedSpaceGB
Write-Host ($vms).Count " VMs found" -ForegroundColor Green  

foreach($vm in $vms){
Write-Host $vm.Name "... " -ForegroundColor Blue -NoNewLine
$vmstat = "" | Select Name, Cluster, Host, PowerState, vCPUs, CPUMax, CPUAvg, CPUMin, vRAM, MemMax, vRAMMax, MemAvg, vRAMAvg, MemMin, vRAMMin, UsedSpaceGB, ProvisionedSpaceGB 
$vmstat.Name = $vm.Name
$vmstat.Cluster = $vm.Cluster
$vmstat.Host = $vm.VMHost
$vmstat.PowerState = $vm.PowerState
$vmstat.vCPUs = $vm.NumCpu
$vmstat.vRAM = $vm.MemoryGB
$vmstat.UsedSpaceGB = $vm.UsedSpaceGB
$vmstat.ProvisionedSpaceGB = $vm.ProvisionedSpaceGB

try {
	$statcpu = Get-Stat -Entity ($vm.Name)-start (get-date).AddDays(-$statsdays) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average -IntervalMins $statsinterval -ErrorAction Stop
}
catch [Exception]{
	Write-Host "no CPU stats ... " -ForegroundColor Red -NoNewLine
}

try {
	$statmem = Get-Stat -Entity ($vm.Name)-start (get-date).AddDays(-$statsdays) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average -IntervalMins $statsinterval -ErrorAction Stop
}
catch [Exception]{
	Write-Host "no Memory stats ... " -ForegroundColor Red -NoNewLine
}

$cpu = 0
$cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
$vmstat.CPUMax = [math]::Round($cpu.Maximum,3)
$vmstat.CPUAvg = [math]::Round($cpu.Average,3)
$vmstat.CPUMin = [math]::Round($cpu.Minimum,3)

$mem = 0
$mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
$vmstat.MemMax = [math]::Round($mem.Maximum,3)
$vmstat.vRAMMax = $vmstat.vRAM*($vmstat.MemMax/100) 
$vmstat.MemAvg = [math]::Round($mem.Average,3)
$vmstat.vRAMAvg = $vmstat.vRAM*($vmstat.MemAvg/100) 
$vmstat.MemMin = [math]::Round($mem.Minimum,3)
$vmstat.vRAMMin = $vmstat.vRAM*($vmstat.MemMin/100) 
$allvms += $vmstat
Write-Host " Done" -ForegroundColor Green
}
$allvms | Export-CSV "C:\VMs.csv" -noTypeInformation
  
#Disconnect from vCenter server
try {
	Disconnect-VIServer -Confirm:$false -ErrorAction Stop | Out-Null
}
catch [Exception]{
	$exception = $_.Exception
	Write-Host "Unable to disconnect : " $exception.InnerException.message -ForegroundColor Red
	Break
}
