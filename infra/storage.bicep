@description('The name of the storage account')
param storageAccountName string

@description('The location of the storage account')
param location string = resourceGroup().location

@description('The SKU of the storage account')
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Create the default blob service and a container named 'notes'
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}

resource notesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: blobService
  name: 'notes'
  properties: {}
}

// Expose useful outputs for consumers
// Use the resource reference to fetch keys (Bicep supports .listKeys())
var primaryKey = storageAccount.listKeys().keys[0].value

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryKey string = primaryKey
output primaryConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${primaryKey};EndpointSuffix=core.windows.net'
