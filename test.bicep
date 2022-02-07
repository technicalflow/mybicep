targetScope = 'subscription'
param deployresourcegroup bool = true
param location string = deployment().location

var rg = 'rg1'
resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployresourcegroup) {
  name: rg
  // location: deployment().location
  location: location
}

module app 'webapp.bicep' = {
  scope: rg1
  name: 'appplan'
}

