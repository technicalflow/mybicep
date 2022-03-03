param itemCount int = 5

var stringArray = [for i in range(0, itemCount): 'item${(i + 1)}']

output arrayResult array = stringArray



param rgLocation string = resourceGroup().location

var subnets = [
  {
    name: 'api'
    subnetPrefix: '10.144.0.0/24'
  }
  {
    name: 'worker'
    subnetPrefix: '10.144.1.0/24'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'vnet'
  location: rgLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.144.0.0/20'
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
      }
    }]
  }
}



param startingInt int = 0001
param numberOfElements int = 1000

output rangeOutput array = range(startingInt, numberOfElements)
output intOutput int = min(0, 1000)
output anyOutput int = any(1000)


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'PIP1'
  location: rgLocation
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'dnsname'
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'NIC1'
  location: rgLocation
  properties: {
    ipConfigurations: [
      {
        name: 'name'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: 'subnet.id'
          }
          publicIPAddress: any((publicIPAddress.id == '') ? null : {
            id: publicIPAddress.id
          })
        }
      }
    ]
  }
}


// output rangeOutput array = range(startingInt, numberOfElements)
output testoutput string = '${uniqueString(resourceGroup().name)}'
output testthreeoutput string = '${uniqueString(resourceGroup().location)}'
output testtwooutput string = '${uniqueString(deployment().name)}1'
