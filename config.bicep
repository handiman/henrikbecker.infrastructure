param resourcePrefix string = resourceGroup().name

resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${resourcePrefix}-config'
  location: resourceGroup().location
  sku: {
    name: 'free'
  }  
  identity: {
    type: 'SystemAssigned'
  }
}
