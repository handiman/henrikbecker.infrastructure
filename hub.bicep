param resourcePrefix string = resourceGroup().name
param location string = resourceGroup().location

resource eventhubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: resourcePrefix
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 1
  }
}

resource eventhub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: '${resourcePrefix}/henrikbecker.net'
  dependsOn: [
    eventhubNamespace
  ]
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

output connectionString string = 'Endpoint=sb://${eventhubNamespace.name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${eventhubNamespace.listKeys().keys[0].value}'
