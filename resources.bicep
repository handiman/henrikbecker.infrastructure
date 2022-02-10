param ownerId string
param publisherEmail string
param publisherName string
param acmeBotFunctionAppName string
param resourcePrefix string = resourceGroup().name

var vaultName = '${resourcePrefix}-vault'
var location = resourceGroup().location
var topicName = resourcePrefix

resource topic 'Microsoft.EventGrid/topics@2021-12-01' = {
  name: topicName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    inputSchema: 'EventGridSchema'
  }
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
  }
}

resource azureAdTenantIdSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'AzureAd--TenantId'
  parent: keyVault
  properties: {
    value: subscription().tenantId
    contentType: 'string'
  }
}

resource azureAdInstanceSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'AzureAd--Instance'
  parent: keyVault
  properties: {
    value: environment().authentication.loginEndpoint
    contentType: 'uri'
  }
}

resource eventGridAccessKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'EventGridAccessKey'
  parent: keyVault 
  properties: {
    value: topic.listKeys().key1
    contentType: 'string'
  }
}

resource vaultPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: keyVault
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
