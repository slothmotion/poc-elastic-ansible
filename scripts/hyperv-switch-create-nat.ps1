param(
	[string]$SwitchName,
	[string]$IPAddress,
	[string]$PrefixLength,
	[string]$NetName,
	[string]$NetMask
)

If ("$SwitchName" -in (Get-VMSwitch | Select-Object -ExpandProperty Name) -eq $FALSE) {
  "Creating internal switch '$SwitchName' on Windows Hyper-V host..."
  New-VMSwitch -SwitchName "$SwitchName" -SwitchType Internal | Out-Null
  "Disabling ipv6 for $SwitchName..."
  Disable-NetAdapterBinding -Name "vEthernet ($SwitchName)" -ComponentID ms_tcpip6 -PassThru | Out-Null
}
else {
  "Switch '$SwitchName' already exists; skipping"
}

If ("$IPAddress" -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $FALSE) {
  "Creating NAT Gateway with IP address $IPAddress ..."
  New-NetIPAddress -IPAddress "$IPAddress" -PrefixLength $PrefixLength -InterfaceAlias "vEthernet ($SwitchName)" | Out-Null
}
else {
  "NAT gateway '$IPAddress' already exists; skipping"
}

If ("$NetMask/$PrefixLength" -in (Get-NetNAT | Select-Object -ExpandProperty InternalIPInterfaceAddressPrefix) -eq $FALSE) {
  "Registering new NAT network for $NetMask/$PrefixLength on Windows Hyper-V host..."
  New-NetNAT -Name "$NetName" -InternalIPInterfaceAddressPrefix "$NetMask/$PrefixLength" | Out-Null
}
else {
  "NAT network '$NetMask/$PrefixLength' already exists; skipping"
}