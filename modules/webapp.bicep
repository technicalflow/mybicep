targetScope = 'resourceGroup'

@description('App Plan Name')
param appplanname string = 'msa-app-plan-1'

@description('App Name')
param appname string = 'msa-app-1'

@description('Location')
param location string = resourceGroup().location

var location_var = location

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appplanname
  location: location_var
  sku: {
    name: 'F1'
    capacity: 1
  }
  tags: {
    'resourceGroup().tags': 'Owner'
  }
}

resource webApplication 'Microsoft.Web/sites@2021-02-01' = { 
  name: appname
  location: location_var
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output webApplicatioHostname string = webApplication.properties.defaultHostName
