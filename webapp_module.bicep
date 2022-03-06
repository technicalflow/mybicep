targetScope = 'subscription'
param deployresourcegroup bool = true
param location string = deployment().location
param prefix string = 'msa'
param acrcount int = 2

var loc = (location == 'francecentral') ? 'frc' : (location == 'germanywestcentral') ? 'gwc' : '${location}'
var rg = '${prefix}_${loc}_rg1'
var containerrg1 = '${prefix}_${loc}_crg1'
var acrname = toLower('${prefix}${loc}acr${uniqueString(containerGroup.id)}')
var websites = [
  {
    name: 'webapp1'
    tag: 'latest'
  }
  {
    name: 'webapp2'
    tag: 'alpine'
  }
]

resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployresourcegroup) {
  name: rg
  location: location
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
  }
}

resource containerGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: containerrg1
  location: location
  tags: {
    Environment: 'Dev/Test'
    Owner: 'Marek'
    Project: 'msa_demo'
  }
}

module webplan 'modules/webplan.bicep' = {
  scope: rg1
  name: '${prefix}${loc}-appplan-deploy'
  params: {
    appplanname: '${prefix}${loc}-appplan'
    location: location
  }
}

module webapp 'modules/webapp.bicep' = [for site in websites: {
  scope: rg1
  name: '${prefix}${loc}-${site.name}-deploy'
  params:{
    appname: '${prefix}${loc}-${site.name}'
    location: location
    appplanid: webplan.outputs.appiid
    dockerimage: 'techfellow/webappa'
    dockerimagetag: site.tag
  }
  dependsOn: [
    webplan
  ]
}]

module acr 'modules/container-registry.bicep' = [for i in range(0, acrcount): {
  scope: containerGroup
  name: '${acrname}${i}-deploy'
  params: {
    name: '${acrname}${i}'
    location: location
  }
}]
