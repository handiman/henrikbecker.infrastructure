param prefix string = resourceGroup().name
param location string = resourceGroup().location
param githubAppId string
param ownerId string

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