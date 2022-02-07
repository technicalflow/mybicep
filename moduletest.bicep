targetScope = 'resourceGroup'

var websites = [
  {
    name: 'myweb1'
    tag: 'dev'
  }
  {
    name: 'myweb2'
    tag: 'prod'
  }
]

resource appServicePlan1 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'appplan1'
  location: resourceGroup().location
  sku: {
    name: 'F1'
    capacity: 1
  }
}
module appService 'webapp.bicep' = [for site in websites: {
  name: site.name
  params: {
    appname: site.name
    appplanname: appServicePlan1.name
    location: 'eastus'
  }
}]
