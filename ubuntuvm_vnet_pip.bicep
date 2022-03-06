targetScope = 'resourceGroup'

@description('The size of the vm')
param vmsize string = 'Standard_B1ms'

@maxLength(10)
param prefix string = 'msa'

@description('VNet name')
param vnetName string = 'vnet001'

@description('Address prefix')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.10.1.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Default'

// @description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
// param dnsLabelPrefix string = toLower('${prefix}-${uniqueString(resourceGroup().id, prefix)}')

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Administrator Username')
param vmadmin string = 'vmadmin'

// @description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
// @allowed([
//   '12.04.5-LTS'
//   '14.04.5-LTS'
//   '16.04.0-LTS'
//   '18.04-LTS'
//   '20.04-LTS'
// ])
// param ubuntuOSVersion string = '20.04-LTS'

param env string = 'dev'

@description('IP Access to resource')
param yourip string = '95.108.30.54' // run curl testip.fun to know yourip

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'
var mainname = '${prefix}${loc}${env}'
// var vmmmainname = toLower('${vmname}-${uniqueString(resourceGroup().id, vmname)}')
var vmname_var = '${mainname}vm001'
var vnetfullname = '${mainname}_${vnetName}'
var publicIPAddressName_var = '${mainname}pip001'
var dnsLabelPrefix = toLower(vmname_var)
var nsgnic = '${mainname}nsg001'
var subnetnsg = '${mainname}${subnet1Name}nsg001'
var nicname_var = '${vmname_var}nic1'
var ipconfig = 'ipconfig1'
var script = '''
#cloud-config
package_upgrade: true
packages:
- htop
- gnupg
- nano
- ufw
- curl
runcmd:
- snap remove lxd
- snap refresh
- snap install lxd
'''
var scriptdeploy = base64(script)
// var cloudinitnginx = 'I2Nsb3VkLWNvbmZpZwpwYWNrYWdlX3VwZ3JhZGU6IHRydWUKcGFja2FnZXM6CiAgLSBuZ2lueAogIC0gY3VybAogIC0gaHRvcAogIC0gdWZ3CnJ1bmNtZDoKICAtIHN5c3RlbWN0bCBlbmFibGUgLS1ub3cgbmdpbngKCg=='

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsgnic
  location: location
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
          sourceAddressPrefix: '${yourip}/32'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsg2 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: subnetnsg
  location: location
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh-network'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '${yourip}/32'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetfullname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource vnet_subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet
  name: subnet1Name
  properties: {
    addressPrefix: subnet1Prefix
    networkSecurityGroup: {
      id: nsg2.id
      properties: {}
    }
  }
}

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddressName_var
  location: location
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
  dependsOn: []
}

resource nicname 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicname_var
  location: location
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
            id: vnet_subnet1.id
          }
          publicIPAddress: {
            id: publicIPAddressName.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  dependsOn: [
    vnet
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmname_var
  location: location
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
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    storageProfile: {
      osDisk: {
        diskSizeGB: 30
        osType: 'Linux'
        createOption: 'FromImage'
        name: 'OSDisk_${vmname_var}'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        // publisher: 'Canonical'
        // offer: 'UbuntuServer'
        // sku: ubuntuOSVersion
        // version: 'latest'

        // publisher: 'debian'
        // offer: 'debian-11'
        // sku: '11-gen2'
        // version: 'latest'

        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmname_var
      adminUsername: vmadmin
      customData: scriptdeploy
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcCtxJmut0DIZm5zaF1t0qadM1pdTrOlbz0N32GQMtaR3PxUYmM3PUozSFuKjsO9wWeLQJ5RYuKkUKhMuObLlUMvTOPulxP+9akNgdZoLn4NPAB4tI0GuSAFzOYsJ9NSKyw83Ed9kBh4Muz1LEVCPefWPCQKjU2oZnMosJ/DVv58UmnbQaVk+25rFu9Bg3Q5WZ63QIMph0Espg1KTjMm5+5ROlUw4X1vecE6XtvCMJNcKdppJP95bVOSLAXs5BBkLPjZx/ZUyH+1p+o6egaYr4PKxrjszDcxthmJ30COiTohQYqQxbmMiQ5arUFKgE9t+yBBKcJ0MsoiM0XTd52OFuqxY2jq4B7kEHrmwbOcsqKp60bN2WJBTQQlwUNnI1iEscF49iGHppe0P0pOmCcQ0adAE7T5JOmdzAR7q0ofVO2LvRBWc8IaFCbzGnw3xJ5xyi7ctXURNLjWIL5LSNoUKkTT2yMS3dM9eAH8z/88UN39Fh8h3KTVbV3tz86OBFudAwbrjcp2Nm2l58oHgCMhIb/5UwEUxHVZyekFIIVI/GHRV536K7jgyiH8JraX4QTeU/+riG2k59JXDPmrhES+BBXd+tSwW3j9Pa58ITp002gsPxn+KHOZQuunDhStn/HEUNqdSjfhHke0KB05/t9VByrNYJ4Jy8Gbt2acL2NZ0j/w== marek@techfellow'
              path: '/home/vmadmin/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
  }
}

output scriptoutput string = scriptdeploy
output publicipdns string = publicIPAddressName.properties.dnsSettings.fqdn
output publicip string = publicIPAddressName.properties.ipAddress
output username string = vm.properties.osProfile.adminUsername
