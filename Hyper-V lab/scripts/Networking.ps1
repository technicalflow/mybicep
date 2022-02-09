# Networking
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.50.228 -PrefixLength 24 -DefaultGateway 192.168.50.210
Set-DnsClientServerAddress -InterfaceAlias ETHERNET -ServerAddresses 192.168.50.1
Get-NetConnectionProfile -InterfaceAlias Ethernet
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private
Get-NetAdapter -Name Ethernet

Get-NetIPAddress
Get-NetIPInterface
Get-NetIPConfiguration
Get-NetRoute
Find-NetRoute
Get-NetAdapterPowerManagement
Get-NetAdapterAdvancedProperty | Select-Object Jumbo
Set-NetAdapterAdvancedProperty -Name Ethernet -DisplayName "Jumbo Packet" -RegistryValue 4088

Rename-Computer -ComputerName sv-test
Add-Computer -DomainName test.local -Credential local.mduo.pl\Administrator -Restart

Test-NetConnection 8.8.8.8 -CommonTCPPort HTTP
Test-NetConnection test.org -TraceRoute 
Test-NetConnection -ComputerName sv-beta -Port 389

Get-DnsClientCache
Clear-DnsClientCache
Resolve-DnsName www.thomasmaurer.ch
Resolve-DnsName www.thomasmaurer.ch -Type MX -Server 8.8.8.8

Get-NetRoute -Protocol Local -DestinationPrefix 192.168*
Get-NetRoute -InterfaceAlias Wi-Fi
New-NetRoute -DestinationPrefix "10.0.0.0/24" -InterfaceAlias "Ethernet" -NextHop 192.168.192.1

Get-NetTCPConnection
Get-NetTCPConnection -State Established

Test-ComputerSecureChannel -Credential domain\admin -Repair

New-NetFirewallRule -DisplayName "Allow Inbound Port 80" -Direction Inbound -LocalPort 80  -Protocol tcp -Action Allow

New-SmbShare -Name testshare -Path c:\Testpath -FullAccess domain\admin -ReadAccess domain\user
