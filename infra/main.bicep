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
      appLocation: 'app/note-taking-app'      // フロントエンドのパス
      apiLocation: 'app/backend'              // API（Node.js）のパス
      outputLocation: 'build'                 // Reactのビルド出力
    }
  }
}

output staticWebAppUrl string = staticWebApp.properties.defaultHostname
