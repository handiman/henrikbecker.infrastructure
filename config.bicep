param resourcePrefix string = resourceGroup().name
param location string = resourceGroup().location

resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${resourcePrefix}-config'
  location: location
  sku: {
    name: 'free'
  }  
  identity: {
    type: 'SystemAssigned'
  }
}
