if ( -not (Test-Path (Join-Path -Path (Get-Location).path -ChildPath ".ssh"))) {
  md -Force "$((Get-Location).path)\.ssh" | Out-Null
  ssh-keygen -t rsa -f "$((Get-Location).path)\.ssh\id_rsa" -q -N "vagrant"
}