param(
	[string]$VMName,
	[string]$SwitchName
)
Get-VM "$VMName" | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "$SwitchName"