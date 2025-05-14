@description('Name of the resource group')
param resourceGroupName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('App Service Plan SKU')
param appServicePlanSku string = 'P1V2'

@description('Backend App Service name')
param backendAppName string

@description('Frontend App Service name')
param frontendAppName string

@description('Storage Account name')
param storageAccountName string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${resourceGroupName}-plan'
  location: location
  sku: {
    name: appServicePlanSku
    tier: 'PremiumV2'
  }
  kind: 'app'
}

resource backendApp 'Microsoft.Web/sites@2022-03-01' = {
  name: backendAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource frontendApp 'Microsoft.Web/sites@2022-03-01' = {
  name: frontendAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

output backendAppUrl string = backendApp.properties.defaultHostName
output frontendAppUrl string = frontendApp.properties.defaultHostName
