param resourcePrefix string = resourceGroup().name
param location string = resourceGroup().location
var defaultSubnetAddressPrefix = '10.0.0.0/24'

resource backendVnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' = {
  name: '${resourcePrefix}-backend-vnet'
  location: location
  properties: {
    addressSpace:{
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: defaultSubnetAddressPrefix
        }
      }
    ]
  }
}

resource backendVnetSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${backendVnet.name}/default'
  dependsOn: [
    backendVnet
  ]
  properties: {
    addressPrefix: defaultSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
        locations: [
          '*'
        ]
      }
    ]
  }
}


output id string = backendVnet.id
output subnetId string = backendVnetSubnet.id
