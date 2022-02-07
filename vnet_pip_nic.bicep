targetScope = 'resourceGroup'
param location string = resourceGroup().location
@description('Address prefix')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.10.1.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Default'

var vnetName = 'VNET123'
var pip = 'true'

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2018-10-01' = {
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

resource vnetName_subnet1Name 'Microsoft.Network/virtualNetworks/subnets@2018-10-01' = {
  parent: vnetName_resource
  name: subnet1Name
  properties: {
    addressPrefix: subnet1Prefix
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
            id: vnetName_subnet1Name.id
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
    vnetName_resource
    //virtualMachine_PIP
  ]
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
