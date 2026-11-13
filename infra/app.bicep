targetScope = 'resourceGroup'

param location string = resourceGroup().location
param projectPrefix string = 'stackloom'
param environmentName string = 'dev'
param registryName string
param containerAppsEnvironmentName string
param runtimeIdentityName string
param imageRepository string = 'stackloom-incident-copilot'
@description('Immutable Git commit SHA used as the container tag.')
param imageTag string
param minReplicas int = 0
param maxReplicas int = 1

var containerAppName = 'ca-${projectPrefix}-${environmentName}'
var commonTags = {
  project: projectPrefix
  environment: environmentName
  owner: 'stackloom-labs'
  costCenter: 'portfolio'
  managedBy: 'bicep'
  release: imageTag
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: registryName
}

resource environment 'Microsoft.App/managedEnvironments@2025-07-01' existing = {
  name: containerAppsEnvironmentName
}

resource runtimeIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: runtimeIdentityName
}

resource app 'Microsoft.App/containerApps@2025-07-01' = {
  name: containerAppName
  location: location
  tags: commonTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${runtimeIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: true
        targetPort: 8000
        transport: 'auto'
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          server: registry.properties.loginServer
          identity: runtimeIdentity.id
        }
      ]
    }
    template: {
      revisionSuffix: take(toLower(imageTag), 10)
      containers: [
        {
          name: 'incident-copilot'
          image: '${registry.properties.loginServer}/${imageRepository}:${imageTag}'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: 8000
                scheme: 'HTTP'
              }
              initialDelaySeconds: 10
              periodSeconds: 30
              failureThreshold: 3
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/health'
                port: 8000
                scheme: 'HTTP'
              }
              initialDelaySeconds: 5
              periodSeconds: 10
              failureThreshold: 6
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output containerAppName string = app.name
output fqdn string = app.properties.configuration.ingress.fqdn
output image string = '${registry.properties.loginServer}/${imageRepository}:${imageTag}'
