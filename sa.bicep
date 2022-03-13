targetScope = 'resourceGroup'
@description('Location')
param location string = resourceGroup().location
param servicename string = 'sa'
param env string = 'Dev'
param prefix string = 'msa'

// param startingInt int = 0001
// param numberOfElements int = 1

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'

var name_var = toLower('${prefix}${loc}${servicename}${env}001')
var sku_var = (env == 'Prod') ? 'Standard_GRS' : 'Standard_LRS'

resource mystorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name_var
  location: location
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'  
    immutableStorageWithVersioning: {
       enabled: true
    }
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    // allowSharedKeyAccess: false
  }
  sku: {
    name: sku_var
  }
  tags: {
    Environment: env 
    Owner: 'Marek'
  }
}

resource mystorageaccountblob 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' ={
  name: 'default'
  parent: mystorageaccount
  properties: {
    changeFeed: {
      enabled: true
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 30
    }
  }
}
resource mystorageaccountcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' ={
  parent: mystorageaccountblob
  name: 'container1'
}

param roleDefinitionResourceId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //contributor role

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'msa-managedid0001'
  location: location
}

resource roleAssignmentsa 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: mystorageaccount
  name: guid(mystorageaccount.id, managedIdentity.id, roleDefinitionResourceId)
  properties: {
    description: 'msaroleassignement'
    roleDefinitionId: roleDefinitionResourceId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output sa_sku object = mystorageaccount.sku
output sa_property object = mystorageaccount.properties.primaryEndpoints
#disable-next-line outputs-should-not-contain-secrets
output mykeys string = mystorageaccount.listKeys().keys[0].value
output mymanagedid string = managedIdentity.properties.principalId
