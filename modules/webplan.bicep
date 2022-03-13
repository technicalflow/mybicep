targetScope = 'resourceGroup'

@description('App Plan Name')
param appplanname string

@description('Location')
param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appplanname
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
}

output appiid string = appServicePlan.id
output appiname string = appServicePlan.name
