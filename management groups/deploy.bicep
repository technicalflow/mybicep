targetScope = 'managementGroup'

@description('Required. The group ID of the Management group')
param name string = 'testMG'

@description('Optional. The friendly name of the management group. If no value is passed then this field will be set to the group ID.')
param displayName string = 'Test MG'

@description('Optional. The management group parent ID. Defaults to current scope.')
param parentId string = '<<managementGroupId>>'

@description('Optional. Array of role assignment objects to define RBAC on this resource.')
param roleAssignments array = [
  {
      'roleDefinitionIdOrName': 'Reader'
      'principalIds': [
          '<<deploymentSpId>>'
      ]
  }
]

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: name
  scope: tenant()
  properties: {
    displayName: displayName
    details: !empty(parentId) ? {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parentId}'
      }
    } : null
  }
}

module managementGroup_rbac 'nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name)}-ManagementGroup-Rbac-${index}'
  params: {
    principalIds: roleAssignment.principalIds
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceName: managementGroup.name
  }
  scope: managementGroup
}]

@description('The name of the management group')
output name string = managementGroup.name

@description('The resource ID of the management group')
output resourceId string = managementGroup.id
