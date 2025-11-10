@description('Location for all resources')
param location string = resourceGroup().location

@description('Static Web App name')
param staticWebAppName string

@description('SKU for Static Web App')
@allowed([
  'Free'
  'Standard'
])
param staticWebAppSku string = 'Free'

@description('GitHubリポジトリURL（例: https://github.com/your-org/your-repo）')
param repositoryUrl string

@description('GitHubブランチ名（例: main）')
param branch string = 'main'

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: staticWebAppSku
    tier: staticWebAppSku
  }
  properties: {
    repositoryUrl: repositoryUrl
    branch: branch
    buildProperties: {
      appLocation: 'app/frontend'      // フロントエンドのパス
  apiLocation: 'app/api'              // API（Functions）のパス
      outputLocation: 'build'                 // Reactのビルド出力
    }
  }
}

// LoadTest （LoadTest.bicep）呼び出し

@description('Load Test name')
param loadTestName string
module loadTest 'loadtest.bicep' = {
  name: 'loadTestModule'
  params: {
    location: location
    LoadTestName: loadTestName  // 任意のリソース名に変更可
  }
}

@description('Storage Account name')
param storageAccountName string

// Deploy storage using the storage module
module storage 'storage.bicep' = {
  name: 'storageModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    sku: 'Standard_LRS'
  }
}

// Create a Consumption App Service plan for Functions (Linux Consumption)
resource functionPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${staticWebAppName}-fn-plan'
  location: location
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
  }
  kind: 'functionapp'
}

// Function App with system-assigned identity
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${staticWebAppName}-functions'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: functionPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storage.outputs.primaryConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

output staticWebAppUrl string = staticWebApp.properties.defaultHostname
output functionAppHostname string = functionApp.properties.defaultHostName
output storageAccountId string = storage.outputs.storageAccountId
