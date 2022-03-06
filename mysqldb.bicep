targetScope = 'resourceGroup'

param prefix string = 'msa'
param location string = resourceGroup().location

@secure()
param adminpass string

resource mySQLdb 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: '${prefix}mysqldb'
  location: location
  properties: {
    administratorLogin: 'administratorLogin'
    administratorLoginPassword: adminpass
    createMode: 'Default'
    minimalTlsVersion: 'TLS1_2'
    storageProfile: {
       backupRetentionDays: 7
    }
    sslEnforcement: 'Enabled'
  }
}

