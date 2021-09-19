targetScope = 'subscription'

param ownerId string
param publisherEmail string
param publisherName string
param prefix string
param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: prefix
  location: location
}

module net 'net.bicep' = {
  name: '${prefix}-net'
  scope: rg
}

module resources 'resources.bicep' = {
  name: '${rg.name}-resources'
  scope: rg
  dependsOn: [
    rg
  ]
  params: {
    ownerId: ownerId
    prefix: prefix
    publisherName: publisherName
    publisherEmail: publisherEmail
  }
}
