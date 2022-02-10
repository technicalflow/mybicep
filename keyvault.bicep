targetScope = 'resourceGroup'

@description('Location')
// @allowed([
//   'francecentral'
//   'germanywestcentral'
// ])
param location string = resourceGroup().location

@maxLength(12)
param env_tag string = 'Dev/Test'

param basename string = 'msa'

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'
var kvname = '${basename}${loc}_kv'

resource mykv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvname
  location: location
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
    Environment: env_tag
    Owner: 'Marek Serba'
  }
}
