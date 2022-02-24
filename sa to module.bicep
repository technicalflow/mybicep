// bicep publish filename --target br:mybicepregistry.azurecr.io/bicep/modules/storage:v1

param newprefix string = 'msa'

//module sacreate 'br:mybicepregistry.azurecr.io/bicep/modules/storage:v1' = {
module sacreate 'modules/sa_module.bicep' = {
    name: 'sa_create'
    parameters: {
       uniqueStorageName: '${newprefix}stg001'
    } 
}

output saname string = sacreate.outputs.stgname