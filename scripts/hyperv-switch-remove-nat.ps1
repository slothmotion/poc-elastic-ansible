param(
	[string]$SwitchName,
	[string]$IPAddress,
	[string]$PrefixLength,
	[string]$NetName,
	[string]$NetMask
)

If ("$NetMask/$PrefixLength" -in (Get-NetNAT | Select-Object -ExpandProperty InternalIPInterfaceAddressPrefix) -eq $TRUE) {
  "$NetMask/$PrefixLength network for static IP configuration is registered; removing..."
  Remove-NetNat –Name "$NetName" -Confirm:$false
}
else {
  "$NetMask/$PrefixLength network for static IP configuration is not registered; skipping"
}

If ("$IPAddress" -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $TRUE) {
  "$IPAddress gateway for static IP configuration is registered; removing..."
  Remove-NetIPAddress -IPAddress "$IPAddress" -Confirm:$false
}
else {
  "$IPAddress gateway for static IP configuration is not registered; skipping"
}

If ("$SwitchName" -in (Get-VMSwitch | Select-Object -ExpandProperty Name) -eq $TRUE) {
  "$SwitchName switch for static IP configuration exists; removing..."
  Remove-VMSwitch –SwitchName "$SwitchName" -Force
}
else {
  "$SwitchName switch for static IP configuration does not exist; skipping"
}
