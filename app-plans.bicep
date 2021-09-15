param prefix string = resourceGroup().name
var location = resourceGroup().location

resource consumptionPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${prefix}-consumption'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
}

resource freePlan 'Microsoft.Web/serverfarms@2021-01-15' =  {
  name: '${prefix}-free'
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource linuxPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${prefix}-linux'
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
output freePlan object = {
  id: freePlan.id
  name: freePlan.name
}
output linuxPlan object = {
  id: linuxPlan.id
  name: linuxPlan.name
}
