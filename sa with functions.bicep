targetScope = 'resourceGroup'
param name string = 'sa'
param env string = 'Dev'

var location = (env == 'Dev') ? 'eastus' : 'westus'

var regions = [
  'francecentral'
  'germanywestcentral'
]

var prefix = 'msa_'
var fullname = '${prefix}${name}'

// adding interpolation for storagename (region,i)
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [ for (region,i) in regions: {
  name: '${fullname}${i}'
  location: region
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}]

resource prodstorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if (env == 'Prod') {
  name: '${fullname}_Prod'
  location: first(regions)
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource devstorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if (env == 'Dev'){
  name: '${fullname}_Dev'
  location: last(regions)
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
  }
}

resource mystorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: '${fullname}_pr'
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
}
