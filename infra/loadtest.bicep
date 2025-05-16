param location string = resourceGroup().location
@description('Location for all resources')

param LoadTestName string 
@description('Load Test name')

param loadTestSku string
@description('Load Test SKU')

param loadTestTier string
@description('Load Test Tier')

// Azure Load TestingリソースのBicep定義サンプル
resource loadTest 'Microsoft.LoadTestService/loadTests@2022-12-01-preview' = {
  name: LoadTestName  // 任意のリソース名に変更可
  location: location // アプリと同じリージョンに変更
  sku: {
    name: loadTestSku
    tier: loadTestTier
  }
  properties: {
    description: 'CI/CD用の負荷テストリソース'
  }
}
