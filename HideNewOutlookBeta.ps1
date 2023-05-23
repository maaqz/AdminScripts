$KeyExists = ((Get-Item "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General").Property | Where-Object { $_ -match "Hide*" }).Count
$PathExists = Test-Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General"

if (($PathExists -eq "true") -and ($KeyExists -eq 0))
{
    New-ItemProperty -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General" -Name "HideNewOutlookToggle" -Value  "1" -PropertyType DWORD -Force -ErrorAction SilentlyContinue
}
elseif ($KeyExists -eq 1)
{
    Write-Output  "The Key exists already"
    exit 0
}
else
{
    Write-Error "Something is wrong"
    exit 1
}


