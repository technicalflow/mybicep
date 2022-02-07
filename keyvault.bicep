targetScope = 'resourceGroup'

@description('Location')
param location string = resourceGroup().location

@maxLength(12)
param env string = 'Dev/Test'

param basename string = 'msa'

var location_var = location
var kvname = '${basename}${location_var}_kv'

resource mykv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvname
  location: location_var
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: 'tenantID'
    accessPolicies: [
      {
        tenantId: 'tenantId'
        objectId: 'objectId'
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
  }
  tags: {
    Environment: env
    Owner: 'Marek Serba'
  }
}
