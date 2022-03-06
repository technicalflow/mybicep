@description('Administrator Username for the local admin account')
param virtualMachineAdminUserName string = 'migrationadm'

@description('Administrator password for the local admin account.')
@secure()
param virtualMachineAdminPassword string

@description('Name of the virtual machine to be created')
@maxLength(15)
param vmNamePrefix string = 'HyperV'

@description('Operating System of the Server')
@allowed([
  'Server2012R2'
  'Server2016'
  'Server2019'
])
param operatingSystem string = 'Server2016'

@description('IP Access to resource')
param yourip string = '95.108.30.54' // run curl testip.fun to know yourip

@description('Globally unique DNS prefix for the Public IPs used to access the Virtual Machines')
@minLength(1)
param dnsPrefixForPublicIP string = 'hypervmigartionlab01'

@description('Location for all resources.')
param location string = resourceGroup().location

var vmfullname_var = [
  '${vmNamePrefix}-VM001'
  '${vmNamePrefix}-VM002'
  '${vmNamePrefix}-AD001'
]

var virtualMachineSize = [
  'Standard_DS3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
]
// Standard_D8d_v4
// Standard_D8a_v4

var VNETName = '${vmNamePrefix}_VNET'
var VNETPrefix = '172.16.0.0/16'
var VNETSubnet1Name = 'HypervSubnet'
var VNETSubnet1Prefix = '172.16.1.0/24'
var diagnosticSAname = 'hypervsadigest'
var pipname = '${vmNamePrefix}_PIP'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', VNETName, VNETSubnet1Name)
var NSGname = '${vmNamePrefix}_NSG1'
var operatingSystemValues = {
  Server2012R2: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2012-R2-Datacenter'
  }
  Server2016: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2016-Datacenter'
  }
  Server2019: {
    PublisherValue: 'MicrosoftWindowsServer'
    OfferValue: 'WindowsServer'
    SkuValue: '2019-Datacenter'
  }
}

resource ASG 'Microsoft.Network/applicationSecurityGroups@2021-05-01' = {
  name: 'ASG'
  location: location
}

resource NSG 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: NSGname
  location: location
  properties: {
    securityRules: [
      {
        name: 'rdp-rule'
        properties: {
          description: 'Allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '${yourip}/32'
          destinationApplicationSecurityGroups: [
            {
              id: ASG.id
            }
          ]
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource VNET 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: VNETName
  location: location
  tags: {
    displayName: VNETName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNETPrefix
      ]
    }
    subnets: [
      {
        name: VNETSubnet1Name
        properties: {
          addressPrefix: VNETSubnet1Prefix
          networkSecurityGroup: {
            id: NSG.id
            properties: {}
          }
        }
      }
    ]
  }
}

resource PUBLICIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: pipname
  location: location
  sku: {
    name:'Basic'
    tier: 'Regional'
  } 
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsPrefixForPublicIP
    }
  }
}

resource NIC 'Microsoft.Network/networkInterfaces@2020-11-01' = [for item in vmfullname_var: {
  name: '${item}_NIC'
  location: location
  properties:  (item == vmfullname_var[2]) ? {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { 
            id: PUBLICIP.id
          } 
          subnet: {
            id: subnetRef
          }
          applicationSecurityGroups: [
          {
            id: ASG.id
          }
          ]
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    } : {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
  }
  dependsOn: [
    VNET
  ]
}]

resource diagnosticstorageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: diagnosticSAname
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
  tags: {
    displayName: 'diagnosticStorageAccount'
  }
  kind: 'StorageV2'
}

resource VM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for item in vmfullname_var: {
  name: item
  location: location
  properties: {
    hardwareProfile: (item == vmfullname_var[2]) ? {
      vmSize: virtualMachineSize[1]
    } : {
      vmSize: virtualMachineSize[2]
    }
    storageProfile: {
      imageReference: {
        publisher: operatingSystemValues[operatingSystem].PublisherValue
        offer: operatingSystemValues[operatingSystem].OfferValue
        sku: operatingSystemValues[operatingSystem].SkuValue
        version: 'latest'
      }
      osDisk: {
        name: '${item}_osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
      }
      dataDisks: (item == vmfullname_var[2]) ? [] : [
        {
          createOption: 'Empty'
          lun: 1
          diskSizeGB: 600
        }
      ]
    }
    osProfile: {
      computerName: item
      adminUsername: virtualMachineAdminUserName
      windowsConfiguration: {
        provisionVMAgent: true
      }
      secrets: []
      adminPassword: virtualMachineAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${item}_NIC')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: diagnosticstorageaccount.properties.primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    NIC
  ]
}]

output Administrator string = virtualMachineAdminUserName
output ResourceLocation string = location
output PublicIP string = PUBLICIP.properties.ipAddress
output PublicDNS object = PUBLICIP.properties.dnsSettings
output VNET array = VNET.properties.ipAllocations
