param resourcePrefix string = resourceGroup().name
var location = resourceGroup().location

resource consumptionPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourcePrefix}-consumption'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
}

resource linuxPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourcePrefix}-linux'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

output consumptionPlan object = {
  id: consumptionPlan.id
  name: consumptionPlan.name
}
output linuxPlan object = {
  id: linuxPlan.id
  name: linuxPlan.name
}
