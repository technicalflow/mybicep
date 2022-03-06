targetScope = 'resourceGroup'

param location string = 'francecentral'
@description('Address prefix')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.10.1.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Default'
param pip bool = true

var vnetName = 'VNET123'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource vnet_subnet1 'Microsoft.Network/virtualNetworks/subnets@2018-10-01' = {
  parent: vnet
  name: subnet1Name
  properties: {
    addressPrefix: subnet1Prefix
  }
}

resource virtualMachine_PIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'msa_test_PIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'msatestpip123'
    }
  }
}

resource vmNIC 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: (pip == 'true') ? { 
            // id: resourceId('Microsoft.Network/publicIPAddresses', 'HyperV-AD001_PIP')
            id: virtualMachine_PIP.id
            } : {} 
          subnet: {
            id: vnet_subnet1.id
          }
          // publicIPAddress: {
          //   id: virtualMachine_PIP.id
          // }
          }
        }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
  }
  dependsOn: [
    vnet
  ]
}

