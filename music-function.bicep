param resourcePrefix string = resourceGroup().name
@secure()
param storageConnectionString string
@secure()
param appConfigConnectionString string
param vaultUri string
param location string = resourceGroup().location

var functionName = '${resourcePrefix}-music'

resource plan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${functionName}-plan'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
}

resource app 'Microsoft.Web/sites@2021-02-01' = {
  name: functionName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      connectionStrings: [
        {
          name: 'AppConfig'
          connectionString: appConfigConnectionString
          type: 'Custom'
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
          value: toLower(functionName)
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

resource config 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${app.name}/web'
  properties: {
    ftpsState: 'Disabled'
  }
}

output identity object = app.identity
