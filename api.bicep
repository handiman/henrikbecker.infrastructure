
@secure()
param storageConnectionString string
@secure()
param serverFarmId string 
@secure()
param appConfigConnectionString string
param resourcePrefix string = resourceGroup().name
param vaultUri string

resource api 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcePrefix}api'
  location: resourceGroup().location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarmId
    siteConfig: {
      connectionStrings: [
        {
          name: 'AppConfig'
          connectionString: appConfigConnectionString
        }
      ]
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: storageConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('${resourcePrefix}api')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'VaultUri'
          value: vaultUri
        }
      ]
    }
  }
}

resource apiConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${resourcePrefix}api/web'
  dependsOn: [
    api
  ]
  properties: {
    ftpsState: 'Disabled'
  }
}

output identity object = api.identity
