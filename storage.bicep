resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${resourceGroup().name}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  name: '${storageAccount.name}/default'
  dependsOn: [
    storageAccount
  ]
}

resource publicContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${blobServices.name}/public'
  dependsOn: [
    blobServices
  ]
  properties: {
    publicAccess: 'Blob'
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  name: '${storageAccount.name}/default'
  dependsOn: [
    storageAccount
  ]
}

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = {
  name: '${storageAccount.name}/default'
  dependsOn: [
    storageAccount
  ]
}

resource contactFormQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  name: '${queueServices.name}/contact-form'
  dependsOn: [
    queueServices
  ]
}

resource salaryFileQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  name: '${queueServices.name}/salary-file'
  dependsOn: [
    queueServices
  ]
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  name: '${storageAccount.name}/default'
  dependsOn: [
    storageAccount
  ]
}

output accountName string = storageAccount.name
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
