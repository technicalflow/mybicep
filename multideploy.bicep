// multi-deployment.bicep

targetScope = 'subscription'

@description('Azure location for all resources')
param location string = 'francecentral'

resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'msa_frc_rg1'
  location: location
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
}

module appService 'webapp.bicep' = {
  scope: resourceGroup(rg1.name)
  name: 'webAppDeployment-${uniqueString(rg1.id)}'
}

resource containerGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-containers-rh'
  location: location
  tags:{
    'Project': 'Bicep Demo'   
  }
}

module containerRegistry 'container-registry.bicep' = {
  scope: resourceGroup(containerGroup.name)
  name: 'acrDeployment-${uniqueString(containerGroup.id)}'
}

resource storageGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-storages-rg'
  location: location
  tags:{
    'Project': 'Bicep Demo'   
  }
}

module bicepStorage 'sa.bicep' = {
  scope: resourceGroup(storageGroup.name)
  name: 'storageDeployment-${uniqueString(storageGroup.id)}'
  params: {
    location: location
    basename: 'acrDeployment-${uniqueString(storageGroup.id)}'
  }
}
