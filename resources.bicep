@secure()
param ownerId string
@secure()
param publisherEmail string
param publisherName string
param prefix string = resourceGroup().name

var vaultName = '${prefix}-vault'
var vaultUri = 'https://${vaultName}${environment().suffixes.keyvaultDns}/' 

module config 'config.bicep' = {
  name: '${prefix}-config'
}

module storage 'storage.bicep' =  {
  name: '${prefix}-storage'
  scope: resourceGroup()
}

module plans 'app-plans.bicep' = {
  name: '${prefix}-plans'
}

module apim 'apim.bicep' = {
  name: '${prefix}-apim'
  params: {
    publisherName: publisherName
    publisherEmail: publisherEmail
  }
}

module web 'web.bicep' = {
  name: '${prefix}-web'
  dependsOn: [
    storage
    config
    plans
    keyVault
  ]
  params: {
    serverFarmId: plans.outputs.linuxPlan.id
    appConfigConnectionString: config.outputs.connectionString
    dockerUserName: keyVault.getSecret('docker--username')
    dockerPassword: keyVault.getSecret('docker--password')
    dockerRegistryUrl: keyVault.getSecret('docker--registryUrl')
    dockerImage: keyVault.getSecret('docker--image--web')
  }
}

module jobs 'jobs.bicep' = {
  name: '${prefix}-jobs' 
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
  name: '${prefix}-api'
  dependsOn: [
    storage
    config
    plans
  ]
  params: {
    serverFarmId: plans.outputs.consumptionPlan.id
    storageConnectionString: storage.outputs.connectionString
    appConfigConnectionString: config.outputs.connectionString
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: resourceGroup().location
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
