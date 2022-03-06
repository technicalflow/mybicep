@minLength(3)
@maxLength(11)
param storagePrefix string
param containerName string = 'container1'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'
param location string = resourceGroup().location

var uniqueStorageName = toLower('${storagePrefix}${uniqueString(resourceGroup().name)}')

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    accessTier: 'Hot'
  }
}

resource sacontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
    name: '${stg.name}/default/${containerName}'
}

output storageEndpoint object = stg.properties.primaryEndpoints
output stgname string = stg.name
output logpath string = '${stg.name}/default/${containerName}'
output stgid string = stg.id
