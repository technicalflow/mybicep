targetScope = 'resourceGroup'

@description('App Name')
param appname string

@description('Location')
param location string = resourceGroup().location

param dockerimage string
param dockerimagetag string

param appplanid string

resource webApplication 'Microsoft.Web/sites@2021-02-01' = { 
  name: appname
  location: location
  // tags: {
  //   'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  // }
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerimage}:${dockerimagetag}'
      appSettings: [
        {
          'name': 'DOCKER_REGISTRY_SERVER_USERNAME'
          'value': ''

        }
        {
          'name': 'DOCKER_REGISTRY_SERVER_PASSWORD'
          'value': ''

        }
        {
          'name': 'DOCKER_REGISTRY_SERVER_URL'
          'value': 'https://index.docker.io'

        }
        {
          'name': 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          'value': 'false'
        }
      ]
    }
    serverFarmId: appplanid
  }
}

// output webApplicatioHostname string = webApplication.properties.defaultHostName
