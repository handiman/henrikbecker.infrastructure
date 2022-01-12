param ownerId string
param publisherEmail string
param publisherName string
param resourcePrefix string = resourceGroup().name

var vaultName = '${resourcePrefix}-vault'
var vaultUri = 'https://${vaultName}${environment().suffixes.keyvaultDns}/' 
var location = resourceGroup().location

module eventhub 'hub.bicep' = {
  name: '${resourcePrefix}-hub'
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

module plans 'app-plans.bicep' = {
  name: '${resourcePrefix}-plans'
}

module apim 'apim.bicep' = {
  name: '${resourcePrefix}-apim'
  params: {
    publisherName: publisherName
    publisherEmail: publisherEmail
  }
}

module web 'web.bicep' = {
  name: '${resourcePrefix}-web'
  dependsOn: [
    storage
    config
    plans
    keyVault
  ]
  params: {
    serverFarmId: plans.outputs.linuxPlan.id
    vaultUri: vaultUri
    appConfigConnectionString: config.outputs.connectionString
    storageConnectionString: storage.outputs.connectionString
    dockerUserName: keyVault.getSecret('docker--username')
    dockerPassword: keyVault.getSecret('docker--password')
    dockerRegistryUrl: keyVault.getSecret('docker--registryUrl')
    dockerImage: keyVault.getSecret('docker--image--web')
  }
}

module jobs 'jobs.bicep' = {
  name: '${resourcePrefix}-jobs' 
  dependsOn: [
    storage
    config
    plans
  ]
  params: {
    vaultUri: vaultUri
    serverFarmId: plans.outputs.consumptionPlan.id
    storageConnectionString: storage.outputs.connectionString
    appConfigConnectionString: config.outputs.connectionString
  }
}

module api 'api.bicep' = {
  name: '${resourcePrefix}-api'
  dependsOn: [
    storage
    config
    plans
  ]
  params: {
    serverFarmId: plans.outputs.consumptionPlan.id
    storageConnectionString: storage.outputs.connectionString
    appConfigConnectionString: config.outputs.connectionString
    vaultUri: vaultUri
  }
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
  name: '${vaultName}/add'
  dependsOn: [
    jobs
    web
    keyVault
  ]
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: jobs.outputs.identity.principalId
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
