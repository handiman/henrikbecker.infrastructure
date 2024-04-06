param publisherEmail string
param publisherName string
param location string = 'West Europe'

resource apim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: resourceGroup().name
  location: location
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
