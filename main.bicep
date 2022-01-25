targetScope = 'subscription'

param resourcePrefix string
param ownerId string
param acmeBot string
param publisherEmail string
param publisherName string  = 'Henrik Becker Consulting AB'
param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourcePrefix
  location: location
}

module net 'net.bicep' = {
  name: '${resourcePrefix}-net'
  scope: rg
}

module resources 'resources.bicep' = {
  name: '${rg.name}-resources'
  scope: rg
  params: {
    ownerId: ownerId
    resourcePrefix: resourcePrefix
    publisherName: publisherName
    publisherEmail: publisherEmail
    acmeBotFunctionAppName: acmeBot
  }
}
