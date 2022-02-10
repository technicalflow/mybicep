targetScope = 'subscription'
param deployresourcegroup bool = true
param location string = deployment().location
param basename string = 'msa'

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'

var rg = '${basename}_${loc}_rg1'

var websites = [
  {
    name: 'mywebapp1'
    tag: 'dev'
  }
  {
    name: 'mywebapp2'
    tag: 'prod'
  }
]

resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployresourcegroup) {
  name: rg
  // location: deployment().location
  location: location
}

module webplan 'modules/webplan.bicep' = {
  scope: rg1
  name: '${basename}${loc}-appplan-deploy'
  params: {
    appplanname: '${basename}${loc}-appplan'
  }
}

module webapp 'modules/webapp.bicep' = [for site in websites: {
  scope: rg1
  name: '${basename}${loc}-${site.name}-deploy'
  params:{
    appname: '${basename}${loc}-${site.name}'
    location: location
    appplanid: webplan.outputs.appiid
    dockerimage: 'techfellow/webappa'
    dockerimagetag: 'latest'
  }
  dependsOn: [
    webplan
  ]
}]
