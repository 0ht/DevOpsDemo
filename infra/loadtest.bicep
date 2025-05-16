param location string = resourceGroup().location
@description('Location for all resources')

param LoadTestName string 
@description('Load Test name')

// Azure Load TestingリソースのBicep定義サンプル
resource loadTest 'Microsoft.LoadTestService/loadTests@2024-12-01-preview' = {
  name: LoadTestName  // 任意のリソース名に変更可
  location: location // アプリと同じリージョンに変更
  properties: {
    description: 'CI/CD用の負荷テストリソース'
  }
}
