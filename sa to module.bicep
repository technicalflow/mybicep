targetScope = 'subscription'
// bicep publish filename --target br:mybicepregistry.azurecr.io/bicep/modules/storage:v1
//module sacreate 'br:mybicepregistry.azurecr.io/bicep/modules/storage:v1' = {

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'existingrgname'  // no need for location property
}
module sacreate 'modules/sa_module.bicep' = {
    name: 'sa_create'
    scope: rg
    params: {
        location: rg.location
        storagePrefix: 'msa'
        uniqueStorageName: 'msastg001'
        containerName: 'c2'
    } 
}

output saname string = sacreate.outputs.stgname
