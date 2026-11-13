targetScope = 'subscription'

@description('Azure region for the StackLoom dev environment.')
param location string = 'canadacentral'

@description('Resource group that forms the workload teardown boundary.')
param resourceGroupName string = 'rg-stackloom-dev-cac'

@description('Short project prefix used in resource names and tags.')
param projectPrefix string = 'stackloom'

@allowed([
  'dev'
])
param environmentName string = 'dev'

@minValue(1)
@description('Monthly cost notification threshold in billing currency. This is not a hard spending cap.')
param monthlyBudgetAmount int = 20

@description('Budget notification recipient supplied by a protected pipeline variable.')
param budgetContactEmail string

@minValue(30)
@maxValue(730)
param logRetentionDays int = 30

@description('First day of a month in UTC.')
param budgetStartDate string = utcNow('yyyy-MM-01')

@description('Budget end date.')
param budgetEndDate string = '2036-12-31'

var commonTags = {
  project: projectPrefix
  environment: environmentName
  owner: 'stackloom-labs'
  costCenter: 'portfolio'
  managedBy: 'bicep'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: '${projectPrefix}-${environmentName}-monthly'
  properties: {
    amount: monthlyBudgetAmount
    category: 'Cost'
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: budgetStartDate
      endDate: budgetEndDate
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          resourceGroup.name
        ]
      }
    }
    notifications: {
      Actual80Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 80
        contactEmails: [
          budgetContactEmail
        ]
      }
      Forecast100Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Forecasted'
        contactEmails: [
          budgetContactEmail
        ]
      }
    }
  }
}

module foundation 'modules/foundation.bicep' = {
  name: 'stackloom-foundation'
  scope: resourceGroup
  params: {
    location: location
    projectPrefix: projectPrefix
    environmentName: environmentName
    logRetentionDays: logRetentionDays
    tags: commonTags
  }
}

output resourceGroupName string = resourceGroup.name
output registryName string = foundation.outputs.registryName
output containerAppsEnvironmentName string = foundation.outputs.containerAppsEnvironmentName
output runtimeIdentityName string = foundation.outputs.runtimeIdentityName
output applicationInsightsName string = foundation.outputs.applicationInsightsName
output budgetName string = budget.name
