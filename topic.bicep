param name string = resourceGroup().name
param location string = resourceGroup().location

resource topic 'Microsoft.EventGrid/topics@2021-12-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    inputSchema: 'CustomEventSchema'
  }
}
