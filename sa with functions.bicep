targetScope = 'resourceGroup'
param name string = 'sa'
param env string = 'dev'
param storageCount int = 2
param createNewStorage bool = true

var location = (env == 'prod') ? 'eastus' : 'westus'

var regions = [
  'francecentral'
  'germanywestcentral'
]

var prefix = 'msa'
var fullname = '${prefix}${name}'

var sku = (env == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

// adding interpolation for storagename (region,i)
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [ for (region,i) in regions: {
  name: '${fullname}${env}${i}'
  location: region
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}]

resource prodstorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if (env == 'prod') {
  name: '${fullname}${env}10'
  location: first(regions)
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    accessTier: 'Hot'
  }
  resource service 'fileServices' = {
    name: 'default'
    resource share 'shares' = {
      name: 'share1'
      properties: {
        accessTier: 'Hot'
        enabledProtocols: 'NFS'
      }
    }
  }
}

resource devstorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if (env == 'dev'){
  name: '${fullname}${env}'
  location: last(regions)
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    accessTier: 'Cool'
  }
}

@batchSize(1)
resource prstorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = [for i in range(0, storageCount): if(createNewStorage) {
  name: 'pr${fullname}${env}${i}'
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
}]

output storageInfo array = [for i in range(0, storageCount): {
  id: prstorageaccount[i].id
  blobEndpoint: prstorageaccount[i].properties.primaryEndpoints.blob
  status: prstorageaccount[i].properties.statusOfPrimary
}]

output storageaccounts array = [for (region, i) in regions: {
  name: storageaccount[i].name
  id: storageaccount[i].id
}]

output arrayLength int = length(regions)

