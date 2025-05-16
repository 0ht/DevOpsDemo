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
      apiLocation: 'app/backend'              // API（Node.js）のパス
      outputLocation: 'build'                 // Reactのビルド出力
    }
  }
}

// LoadTest （LoadTest.bicep）呼び出し

@description('Load Test name')
param loadTestName string

@description('Load Test SKU')
param loadTestSku string 

@description('Load Test Tier')
param loadTestTier string

module loadTest 'loadtest.bicep' = {
  name: 'loadTestModule'
  params: {
    location: 'japaneast' 
    LoadTestName: loadTestName  // 任意のリソース名に変更可
    loadTestSku: loadTestSku
    loadTestTier: loadTestTier
  }
}

output staticWebAppUrl string = staticWebApp.properties.defaultHostname
