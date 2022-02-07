targetScope = 'subscription'

param location string = 'francecentral'

resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'msa_frc_rg1'
  location: location
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
}

module acr 'container-registry.bicep' = {
  scope: resourceGroup(rg1.name)
  name: 'mynewacr_${uniqueString(rg1.id)}'
  params: {
    basename: 'mynewacr'
    location: location
  }
}

module webappnew 'webapp.bicep' = {
  scope: resourceGroup(acr.name)
  name: 'webappnew'
  params: {
    appname: 'webappnewname'
    location: location
  }
}
