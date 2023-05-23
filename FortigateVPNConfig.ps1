
# Declaration
$ExeExists = Test-Path "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"
$RegExists = Test-Path "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname" 

# IF FortiClient.exe exists and SSL tunnel is NOT present in the registry, THEN create registry entry and a functional VPN configuration.

if ($ExeExists -eq $True -and $RegExists -ne $True)
{
   New-Item "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname" -force -ea SilentlyContinue # the last part of the reg-key declares the Name of the VPN-Tunnel
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname' -Name 'Description' -Value 'DESCRIPTIONNAME' -PropertyType String -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname' -Name 'Server' -Value 'SSLTUNNELIP' -PropertyType String -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname' -Name 'promptusername' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname' -Name 'promptcertificate' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Tunnelname' -Name 'ServerCert' -Value '0' -PropertyType String -Force -ea SilentlyContinue
   exit 0
}
# Throw STD_ERR
else 
{
   Write-Host "Die VPN ist bereits konfiguriert" -ErrorAction SilentlyContinue
   exit 1
}


