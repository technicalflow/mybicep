targetScope = 'resourceGroup'
@description('Location')
param location string = resourceGroup().location

param basename string = 'msa'

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'
var acrname = '${basename}${loc}acr'
var sku = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrname
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

output acrloginServer string = containerRegistry.properties.loginServer
output acradminUser bool = containerRegistry.properties.adminUserEnabled
output acrregistryName string = containerRegistry.name
