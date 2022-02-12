targetScope = 'resourceGroup'
param name string = 'sa'
param env string = 'dev'

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

resource prstorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: '${fullname}${env}pr'
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
}
