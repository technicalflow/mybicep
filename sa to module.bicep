targetScope = 'subscription'

param existingrg string = 'msa_frc_rg1'
param prefix string = 'msa'
// bicep publish filename --target br:mybicepregistry.azurecr.io/bicep/modules/storage:v1
//module sacreate 'br:mybicepregistry.azurecr.io/bicep/modules/storage:v1' = {

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: existingrg  // no need for location property
}
module sacreate 'modules/sa_module.bicep' = {
    name: '${prefix}deploy'
    scope: rg
    // scope: resourceGroup('msa_frc_rg1')
    params: {
        location: rg.location
        storagePrefix: prefix
        containerName: 'container1'
        storageSKU: 'Premium_LRS'
    } 
}

output saname string = sacreate.outputs.stgname
