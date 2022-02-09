param ownerId string
param publisherEmail string
param publisherName string
param acmeBotFunctionAppName string
param resourcePrefix string = resourceGroup().name

var vaultName = '${resourcePrefix}-vault'
var vaultUri = 'https://${vaultName}${environment().suffixes.keyvaultDns}/' 
var location = resourceGroup().location

module topic 'topic.bicep' = {
  name: '${resourcePrefix}-eventgrid-topic'
}

module backendVnet 'vnet.bicep' = {
  name: '${resourcePrefix}-backend-vnet'
}

module config 'config.bicep' = {
  name: '${resourcePrefix}-config'
}

module storage 'storage.bicep' =  {
  name: '${resourcePrefix}-storage'
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${resourcePrefix}-workspace'
  location: location
}

module web 'web.bicep' = {
  name: '${resourcePrefix}-web'
  dependsOn: [
    storage
    config
  ]
  params: {
    vaultUri: vaultUri
    workspaceName: workspace.name
    appConfigConnectionString: config.outputs.connectionString
    storageConnectionString: storage.outputs.connectionString
    dockerUserName: keyVault.getSecret('docker--username')
    dockerPassword: keyVault.getSecret('docker--password')
    dockerRegistryUrl: keyVault.getSecret('docker--registryUrl')
    dockerImage: keyVault.getSecret('docker--image--web')
  }
}

module apim 'apim.bicep' = {
  name: '${resourcePrefix}-apim'
  params: {
    publisherName: publisherName
    publisherEmail: publisherEmail
  }
}

resource acmeBot 'Microsoft.Web/sites@2021-02-01' existing = {
  name: acmeBotFunctionAppName
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  dependsOn: [
    backendVnet
  ]
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

resource vaultPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: keyVault
  dependsOn: [
    web
  ]
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: acmeBot.identity.principalId
        permissions: {
          certificates: [
            'backup'
            'create'
            'delete'
            'deleteissuers'
            'get'
            'getissuers'
            'import'
            'list'
            'listissuers'
            'managecontacts'
            'manageissuers'
            'recover'
            'restore'
            'setissuers'
            'update'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: web.outputs.identity.principalId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: ownerId
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
        }
      }
    ]
  }
}
