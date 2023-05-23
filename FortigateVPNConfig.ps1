
# Declaration
$ExeExists = Test-Path "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"
$RegExists = Test-Path "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft"

# IF FortiClient.exe exists and SSL tunnel is NOT present in the registry, THEN create registry entry and a functional VPN configuration.
if ($ExeExists -eq $True -and $RegExists -ne $True)
{
   New-Item "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft" -force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft' -Name 'Description' -Value 'Heuft' -PropertyType String -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft' -Name 'Server' -Value 'vpn.heuft1700.com' -PropertyType String -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft' -Name 'promptusername' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft' -Name 'promptcertificate' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue
   New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\Heuft' -Name 'ServerCert' -Value '0' -PropertyType String -Force -ea SilentlyContinue
   exit 0
}
# Throw STD_ERR
else 
{
   Write-Host "Die VPN ist bereits konfiguriert" -ErrorAction SilentlyContinue
   exit 1
}


