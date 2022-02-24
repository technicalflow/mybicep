targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'msa'
param vnetSettings object = {
    addressPrefixes: [
        '10.10.0.0/20'
    ]
    subnets: [
        {
            name: subnet1
            addressPrefix: 10.10.0.0/24'
        }
    ]
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
    name: 'vnet1'
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: vnetSettings.addressPrefixes
        }
        subnets: [ for subnet in vnetSettings.subnets: {
            name: subnet.name
            properties: {
                addressPrefix: subnet.addressPrefix
                networkSecurityGroup: {
                    id: NSG.id
                }
                primaryEndpointNetworkPolicies: 'disabled'
            }
        }
        ]
    }
}

resource NSG 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
    name: '${prefix}-NSG'
    location: location
    properties: {
        securityRules: [
        ]
    }
}

resource COSMOSDB 'Microsoft.DocumentDB/databaseAccounts@2020-11-01' = {
    name: '${prefix}-cosmosdb-001'
    location: location
    kind: 'GlobalDocumentDB'
    properties: {
        consistencyPolicy: {
            defaultConsistencyLevel: 'Session'
        }
        locations: [
            {
                locationName: location
                failoverPriority: 0
            }
        ]
        databaseAccountOfferType: 'Standard'
        enableAutomaticFailover: true
        capabilities: [
            {
                name: 'EnableServerless'
            }
        ]
    }
}

resource COSMOSDB-SQLDB 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-11-01' = {
    name: '${prefix}${COSMOSDB.name}-SQLDB'
    parent: COSMOSDB
    properties: {
        resource: {
            id: '${COSMOSDB.name}-SQLDB'
        }
        options: {}
    }
}

resource sqlContainerName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  parent: COSMOSDB-SQLDB
  name: '${prefix}-orders'
  properties: {
    resource: {
      id: '${prefix}-orders'
      partitionKey: {
        paths: [
          '/id'
        ]
      }
    }
    options: {}
  }
}

resource CDB-DNS 'Microsoft.Network/privateDnsZones@2020-11-01' = {
    name: 'privatelink.documents.azure.com'
    location: 'global'
}

resource CDB-DNS-LINK 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-11-01' = {
    name: '${prefix}-cosmosdb-dns-link'
    location: 'global'
    parent: CBD-DNS
    properties: {
        registrationEnabled: false
        virtualNetwork: {
            id: vnet.id
        }
    }
}


resource cosmosPrivateEndpoint 'Microsoft.Network/privateEndpoints@2019-04-01'  = {
  name: '${prefix}-cosmos-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${prefix}-cosmos-pe'
        properties: {
          privateLinkServiceId: COSMOSDB.id
          groupIds: [
            'SQL'
          ]
        }
      }
    ]
    subnet: { 
      id: vnet.properties.subnets[0].id
    }
  }
}

resource cosmosPrivateEndpointDnsLink 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name:'${prefix}-cosmos-pe-dns'
  parent: cosmosPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.documents.azure.com'
        properties: {
          privateDnsZoneId: CBD-DNS.id
        }
      }
    ]
  }
}
