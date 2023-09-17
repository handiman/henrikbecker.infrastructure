param prefix string = resourceGroup().name
param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
    name: prefix
    location: location
    sku: {
        name: 'Basic'
    }
    properties: {
        adminUserEnabled: false
        anonymousPullEnabled: false
        dataEndpointEnabled: false
        publicNetworkAccess: 'Enabled'
        networkRuleBypassOptions: 'AzureServices'
        zoneRedundancy: 'Disabled'
        policies: {
            quarantinePolicy: {
                status: 'disabled'
            }
            trustPolicy: {
                type: 'Notary'
                status: 'disabled'
            }
            retentionPolicy: {
                days: 7
                status: 'disabled'
            }
            exportPolicy: {
                status: 'enabled'
            }
            azureADAuthenticationAsArmPolicy: {
                status: 'enabled'
            }
            softDeletePolicy: {
                retentionDays: 7
                status: 'disabled'
            }
        }
        encryption: {
            status: 'disabled'
        }
    }
}

resource containerRegistryAdmin 'Microsoft.ContainerRegistry/registries/scopeMaps@2023-06-01-preview' = {
    name: 'adminscope'
    parent: containerRegistry
    properties: {
        description: 'Can perform all read, write and delete operations on the registry'
        actions: [
            'repositories/${prefix}/metadata/read'
            'repositories/${prefix}/metadata/write'
            'repositories/${prefix}/content/read'
            'repositories/${prefix}/content/write'
            'repositories/${prefix}/content/delete'
        ]
    }
}

resource containerRegistryPull 'Microsoft.ContainerRegistry/registries/scopeMaps@2023-06-01-preview' = {
    name: 'pullscope'
    parent: containerRegistry
    properties: {
        description: 'Can pull any repository of the registry'
        actions: [
            'repositories/${prefix}/content/read'
        ]
    }
}

resource containerRegistryPush 'Microsoft.ContainerRegistry/registries/scopeMaps@2023-06-01-preview' = {
    name: 'pushscope'
    parent: containerRegistry
    properties: {
        description: 'Can push to any repository of the registry'
        actions: [
            'repositories/${prefix}/content/read'
            'repositories/${prefix}/content/write'
        ]
    }
}