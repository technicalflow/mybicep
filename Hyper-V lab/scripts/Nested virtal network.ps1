#nested virtualization network config

$swName = "InternalNATSwitch"
New-VMSwitch -Name $swName -SwitchType Internal

$index = Get-NetAdapter | where {$_.Name -like "*InternalNATSwitch*"} |select ifIndex

New-NetIPAddress -IPAddress 192.168.2.1 -PrefixLength 24 -InterfaceIndex $index.ifIndex
New-NetNat -Name $swName -InternalIPInterfaceAddressPrefix 192.168.2.0/24