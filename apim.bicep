param publisherEmail string
param publisherName string

resource apim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: resourceGroup().name
  location: 'West Europe'
  identity: {
    type: 'SystemAssigned'
  }
  sku:{
    name: 'Consumption'
    capacity: 0
  }
  properties:{
    virtualNetworkType: 'None'
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}
