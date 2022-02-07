targetScope = 'resourceGroup'
@description('Location')
param location string = resourceGroup().location

param env string = 'Dev/Test'
param basename string = 'msa'

var location_var = location
var name_var = '${basename}${location_var}sa'
var sku_var = (env == 'Production') ? 'Standard_GRS' : 'Standard_LRS'

resource mystorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name_var
  location: location_var
  kind: 'StorageV2'
  sku: {
    name: sku_var
  }
  tags: {
    Environment: env 
    Owner: 'Marek Serba'
  }
}

resource mystorageaccountblob 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' ={
  name: 'default'
  parent: mystorageaccount

}
resource mystorageaccountcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' ={
  parent: mystorageaccountblob
  name: 'container1'
}

output sa_sku object = mystorageaccount.sku
output sa_property object = mystorageaccount.properties.primaryEndpoints
