param zoneName string = 'henrikbecker.net'
param location string = resourceGroup().location

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${zoneName}.ip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
