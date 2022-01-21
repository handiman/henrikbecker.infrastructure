param resourcePrefix string = resourceGroup().name
@secure()
param storageConnectionString string
@secure()
param serverFarmId string 
@secure()
param appConfigConnectionString string
param vaultUri string

resource economyFunction 'Microsoft.Web/sites@2021-02-01' = {
  name: '${resourcePrefix}-economy'
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
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('${resourcePrefix}-mail')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
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


resource mailFunctionConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${resourcePrefix}api/web'
  dependsOn: [
    economyFunction
  ]
  properties: {
    ftpsState: 'Disabled'
  }
}

output identity object = economyFunction.identity
