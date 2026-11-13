param location string
param projectPrefix string
param environmentName string
param logRetentionDays int
param tags object

var suffix = toLower(uniqueString(subscription().id, resourceGroup().id))
var compactPrefix = replace(toLower(projectPrefix), '-', '')
var registryName = take('${compactPrefix}${environmentName}${suffix}', 50)
var logAnalyticsName = 'log-${projectPrefix}-${environmentName}'
var appInsightsName = 'appi-${projectPrefix}-${environmentName}'
var environmentResourceName = 'cae-${projectPrefix}-${environmentName}'
var identityName = 'id-${projectPrefix}-${environmentName}'
var acrPullRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    policies: {
      retentionPolicy: {
        days: 7
        status: 'enabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
    }
  }
}

resource runtimeIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, runtimeIdentity.id, acrPullRoleDefinitionId)
  scope: registry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: runtimeIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    retentionInDays: logRetentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  sku: {
    name: 'PerGB2018'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2025-07-01' = {
  name: environmentResourceName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: listKeys(logAnalytics.id, logAnalytics.apiVersion).primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

output registryName string = registry.name
output registryLoginServer string = registry.properties.loginServer
output containerAppsEnvironmentName string = containerAppsEnvironment.name
output runtimeIdentityName string = runtimeIdentity.name
output applicationInsightsName string = applicationInsights.name
