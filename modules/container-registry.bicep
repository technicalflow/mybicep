targetScope = 'resourceGroup'


@description('Location')
param location string = resourceGroup().location

param name string

// var acrname = '${basename}${loc}-acr'
var sku = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

output acrloginServer string = containerRegistry.properties.loginServer
output acrid string = containerRegistry.id
output acradminUser bool = containerRegistry.properties.adminUserEnabled
output acrregistryName string = containerRegistry.name
