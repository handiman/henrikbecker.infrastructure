@secure()
param vaultUri string
@secure()
param storageConnectionString string
@secure()
param serverFarmId string 
@secure()
param appConfigConnectionString string
param resourcePrefix string = resourceGroup().name

resource jobs 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcePrefix}jobs'
  location: resourceGroup().location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarmId
    httpsOnly: true
    clientCertMode: 'Optional'
    siteConfig: {
      ipSecurityRestrictions: [
        {
          action: 'Deny'
          priority: 1
          description: 'Deny All'
          ipAddress: '0.0.0.0/0'
        }
      ]
      connectionStrings: [
        {
          name: 'AppConfig'
          connectionString: appConfigConnectionString
        }
      ]
      appSettings: [
        {
          name: 'VaultUri'
          value: vaultUri
        }
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
          value: toLower('${resourcePrefix}jobs')
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

resource jobsConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${resourcePrefix}jobs/web'
  dependsOn: [
    jobs
  ]
  properties: {
    ftpsState: 'Disabled'
  }
}

output identity object = jobs.identity
