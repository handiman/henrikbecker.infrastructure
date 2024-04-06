param ownerId string
param githubAppId string
param publisherEmail string
param publisherName string
param acmeBotFunctionAppName string
param resourcePrefix string = resourceGroup().name
param location string = resourceGroup().location

var vaultName = '${resourcePrefix}-vault'
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

module containerRegistry 'registry.bicep' = {
  name: '${resourcePrefix}-registry'
  params: {
    location: location
  }
}

module backendVnet 'vnet.bicep' = {
  name: '${resourcePrefix}-backend-vnet'
  params: {
    location: location
  }
}

module config 'config.bicep' = {
  name: '${resourcePrefix}-config'
  params: {
    location: location
  }
}

module storage 'storage.bicep' =  {
  name: '${resourcePrefix}-storage'
  params: {
    location: location
  }
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

module acmeBot 'br:cracmebotprod.azurecr.io/bicep/modules/keyvault-acmebot:v3' = {
  name: '${resourcePrefix}-${acmeBotFunctionAppName}'
  params: {
    appNamePrefix: acmeBotFunctionAppName
    mailAddress: 'spam@henrikbecker.se'
    acmeEndpoint: 'https://acme-v02.api.letsencrypt.org/'
    createWithKeyVault: false
    keyVaultBaseUrl: 'https://${vaultName}${environment().suffixes.keyvaultDns}'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: vaultName
  resource vaultPolicies 'accessPolicies' = {
    name: 'add'
    properties: {
      accessPolicies: [
        {
          tenantId: subscription().tenantId
          objectId: acmeBot.outputs.principalId
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
