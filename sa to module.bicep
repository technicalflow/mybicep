param newprefix string = 'msa'

module sacreate 'modules/sa_module.bicep' = {
    name: 'sa_create'
    parameters: {
       uniqueStorageName: '${newprefix}stg001'
    } 
}

output saname string = sacreate.outputs.stgname