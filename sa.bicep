targetScope = 'resourceGroup'
@description('Location')
param location string = resourceGroup().location
param servicename string = 'sa'
param env string = 'Dev'
param prefix string = 'msa'

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'

var name_var = '${prefix}${loc}${servicename}_${env}'
var sku_var = (env == 'Prod') ? 'Standard_GRS' : 'Standard_LRS'

resource mystorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name_var
  location: location
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
