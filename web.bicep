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
param location string = resourceGroup().location
param workspaceName string

resource plan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourcePrefix}-linux'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
}

resource insights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${resourcePrefix}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.OperationalInsights/workspaces/${workspace.name}'
  }
}

resource web 'Microsoft.Web/sites@2018-11-01' = {
  name: resourcePrefix
  location: location
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
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insights.properties.ConnectionString
        }
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
