@description('The size of the vm')
param vmsize string = 'Standard_B1ms'

@maxLength(10)
param vmname string = 'msa'

@description('VNet name')
param vnetName string = 'VNet1'

@description('Address prefix')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.10.1.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Default'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmname}-${uniqueString(resourceGroup().id, vmname)}')

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Administrator Username')
param vmadmin string = 'madmin'

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  '12.04.5-LTS'
  '14.04.5-LTS'
  '16.04.0-LTS'
  '18.04-LTS'
])
param ubuntuOSVersion string = '18.04-LTS'

var vmmmainname = toLower('${vmname}-${uniqueString(resourceGroup().id, vmname)}')
var vmmodifiedname_var = '${vmmmainname}_VM'
var publicIPAddressName_var = '${vmmmainname}_PIP'
var location_var = location
var nsgmodifiedname_var = '${vmmmainname}_NSG'
var nicname_var = '${vmmmainname}_NIC'
var ipconfig = 'ipconfig_${nicname_var}'

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2018-10-01' = {
  name: vnetName
  location: location_var
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource vnetName_subnet1Name 'Microsoft.Network/virtualNetworks/subnets@2018-10-01' = {
  parent: vnetName_resource
  name: subnet1Name
  properties: {
    addressPrefix: subnet1Prefix
  }
}

resource nsgmodifiedname 'Microsoft.Network/networkSecurityGroups@2015-06-15' = {
  name: nsgmodifiedname_var
  location: location_var
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '95.108.30.54/32'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  dependsOn: [
    vnetName_subnet1Name
  ]
}

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2018-01-01' = {
  name: publicIPAddressName_var
  location: location_var
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
  dependsOn: []
}

resource nicname 'Microsoft.Network/networkInterfaces@2015-06-15' = {
  name: nicname_var
  location: location_var
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
  properties: {
    ipConfigurations: [
      {
        name: ipconfig
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetName_subnet1Name.id
          }
          publicIPAddress: {
            id: publicIPAddressName.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgmodifiedname.id
    }
  }
  dependsOn: [
    vnetName_resource
  ]
}

resource vmmodifiedname 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmmodifiedname_var
  location: location_var
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicname.id
          properties: {}
        }
      ]
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        name: 'OSDisk_${vmmodifiedname_var}'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOSVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmname
      adminUsername: vmadmin
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcCtxJmut0DIZm5zaF1t0qadM1pdTrOlbz0N32GQMtaR3PxUYmM3PUozSFuKjsO9wWeLQJ5RYuKkUKhMuObLlUMvTOPulxP+9akNgdZoLn4NPAB4tI0GuSAFzOYsJ9NSKyw83Ed9kBh4Muz1LEVCPefWPCQKjU2oZnMosJ/DVv58UmnbQaVk+25rFu9Bg3Q5WZ63QIMph0Espg1KTjMm5+5ROlUw4X1vecE6XtvCMJNcKdppJP95bVOSLAXs5BBkLPjZx/ZUyH+1p+o6egaYr4PKxrjszDcxthmJ30COiTohQYqQxbmMiQ5arUFKgE9t+yBBKcJ0MsoiM0XTd52OFuqxY2jq4B7kEHrmwbOcsqKp60bN2WJBTQQlwUNnI1iEscF49iGHppe0P0pOmCcQ0adAE7T5JOmdzAR7q0ofVO2LvRBWc8IaFCbzGnw3xJ5xyi7ctXURNLjWIL5LSNoUKkTT2yMS3dM9eAH8z/88UN39Fh8h3KTVbV3tz86OBFudAwbrjcp2Nm2l58oHgCMhIb/5UwEUxHVZyekFIIVI/GHRV536K7jgyiH8JraX4QTeU/+riG2k59JXDPmrhES+BBXd+tSwW3j9Pa58ITp002gsPxn+KHOZQuunDhStn/HEUNqdSjfhHke0KB05/t9VByrNYJ4Jy8Gbt2acL2NZ0j/w== marek@techfellow'
              path: '/home/madmin/.ssh/authorized_keys'
            }
            {
              keyData: 'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABw9mlMPp1pSyqeei9JwAdLaakAj3826sLxHeuwupLUo6IGTEgXA3Uw91BBlfewOuZdxFyg2uvzhBWWMYsXsdvFFAAYw80nwWM3P2j9GIo9kRBzZcM7qSrhVSXUM/sKh7ospUdqLQqzED/umoi5wzqYWYbBMX7pGYaHUpNqOOuDQD4/Iw== marek@techfellow\r\n'
              path: '/home/"vmadmin"/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
  }
}
