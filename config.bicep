param prefix string = resourceGroup().name

resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${prefix}-config'
  location: resourceGroup().location
  sku: {
    name: 'free'
  }  
  identity: {
    type: 'SystemAssigned'
  }
}

output connectionString string = config.listkeys().value[0].connectionString
output identity object = config.identity
