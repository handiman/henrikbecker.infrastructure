param resourceName string = resourceGroup().name
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: resourceName
  location: location
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
  parent: storageAccount
  name: 'default'
}

resource publicContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: blobServices
  name: 'public'
  properties: {
    publicAccess: 'Blob'
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}

resource contactFormQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  parent: queueServices
  name: 'contact-form'
}

resource salaryFileQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  parent: queueServices
  name: 'salary-file'
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}
