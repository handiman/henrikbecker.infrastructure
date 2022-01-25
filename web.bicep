@secure()
param appConfigConnectionString string
@secure() 
param storageConnectionString string
@secure()
param dockerUserName string
@secure()
param dockerPassword string
@secure()
param dockerRegistryUrl string
@secure()
param dockerImage string
param vaultUri string
param resourcePrefix string = resourceGroup().name

resource plan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourcePrefix}-linux'
  location: resourceGroup().location
  kind: 'linux'
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

resource web 'Microsoft.Web/sites@2018-11-01' = {
  name: resourcePrefix
  location: resourceGroup().location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: 'DOCKER|${dockerImage}:latest'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerUserName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'VaultUri'
          value: vaultUri
        }
      ]
      connectionStrings: [
        {
          name: 'AppConfig'
          connectionString: appConfigConnectionString
          type: 'Custom'
        }
        {
          name: 'Storage'
          connectionString: storageConnectionString
          type: 'Custom'
        }
      ]
      defaultDocuments: [
        'index.html'
        'index.cshtml'
      ]
    }
  }
}

resource webConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${web.name}/web'
  properties: {
    healthCheckPath: '/health'
  }
}

output identity object = web.identity
