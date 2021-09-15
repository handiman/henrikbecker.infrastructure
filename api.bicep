
@secure()
param storageConnectionString string
@secure()
param serverFarmId string 
@secure()
param appConfigConnectionString string
param prefix string = resourceGroup().name

resource api 'Microsoft.Web/sites@2020-12-01' = {
  name: '${prefix}api'
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
          value: toLower('${prefix}api')
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
      ]
    }
  }
}

resource apiConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${prefix}api/web'
  dependsOn: [
    api
  ]
  properties: {
    ftpsState: 'Disabled'
  }
}

output identity object = api.identity
