# ステップ6：負荷テスト（Azure Load Testing + GitHub Actions）

## 目的
アプリケーションのスケーラビリティと耐久性を検証
CI/CDパイプラインに組み込んで、デプロイ後に自動で負荷テストを実行

## 詳細手順

## 1. Azure Load Testingリソースの作成

### (A) Azure Portalから作成
1. Azureポータルで「Azure Load Testing」を検索し「作成」
2. 必要事項を入力：
   - リソース名：例）loadtest-demo
   - リージョン：アプリと同じリージョン
   - リソースグループ：例）demo-rg
3. 作成後、テストプランを作成（例：100ユーザーが30秒間アクセス）

### (B) Azure CLI/Bicepで作成（自動化向け）
```pwsh
az load test create \
  --name loadtest-demo \
  --resource-group demo-rg \
  --location eastasia
```
またはinfra/main.bicepにLoad Testingリソースを追加し、Bicepで一括デプロイも可能。

#### Bicepサンプル（infra/main.bicepへの追加例）
```bicep
resource loadTest 'Microsoft.LoadTestService/loadTests@2024-12-01-preview' = {
  name: 'loadtest-demo'
  location: 'eastasia' // アプリと同じリージョンに変更
  sku: {
    name: 'LT-S0'
    tier: 'Standard'
  }
  properties: {
    description: 'CI/CD用の負荷テストリソース'
  }
}
```
- `name`, `location`はご自身の環境に合わせて修正してください。
- 既存のmain.bicepに追記し、`az deployment group create`等で一括デプロイできます。


## 2. テストスクリプト（JMeter形式）の準備
1. JMeterでテストシナリオ（例：loadtest.jmx）を作成
   - 例：100ユーザーが30秒間`https://<your-app>.azurestaticapps.net/api/notes`にアクセス
2. `loadtest/`フォルダを作成し、`loadtest.jmx`を配置

#### JMeterスクリプト例（抜粋）
```xml
<ThreadGroup>
  <stringProp name="ThreadGroup.num_threads">100</stringProp>
  <stringProp name="ThreadGroup.duration">30</stringProp>
  <HTTPSamplerProxy>
    <stringProp name="HTTPSampler.domain"><your-app>.azurestaticapps.net</stringProp>
    <stringProp name="HTTPSampler.path">/api/notes</stringProp>
    <stringProp name="HTTPSampler.method">GET</stringProp>
  </HTTPSamplerProxy>
</ThreadGroup>
```

## 3. GitHub Actionsワークフロー統合

### (A) 必要なSecretsの登録
- Azureサービスプリンシパル情報（JSON形式）を`AZURE_CREDENTIALS`として登録
  - 作成例：
    ```pwsh
    az ad sp create-for-rbac --name "loadtest-sp" --sdk-auth
    ```
- サブスクリプションIDを`AZURE_SUBSCRIPTION_ID`として登録

### (B) ワークフロー例（.github/workflows/loadtest.yml）
```yaml
name: Azure Load Test

on:
  workflow_dispatch:
  push:
    branches: [main]

jobs:
  loadtest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Run Azure Load Testing
        uses: azure/load-testing@v1
        with:
          loadTestConfigFile: loadtest/loadtest.jmx
          resourceGroup: demo-rg
          loadTestResource: loadtest-demo
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          env: |
            TARGET_ENDPOINT=https://<your-app>.azurestaticapps.net/api/notes
          passFailCriteria: |
            - avg(response_time_ms) < 2000
            - error_rate < 1

      - name: アーティファクトとして結果を保存
        uses: actions/upload-artifact@v4
        with:
          name: loadtest-results
          path: .azureloadtestrun/**
```
- `passFailCriteria`でSLA（例：平均応答2秒未満、エラー率1%未満）を設定し、超過時はジョブが失敗します。
- 結果はActionsログやアーティファクトで確認可能。

## 4. 結果の確認
- GitHub Actionsのログでテスト結果・SLA判定を確認
- Azure Portal > Load Testingリソースで詳細レポート（レスポンスタイム、エラー率、スループット等）を確認

## 5. 補足Tips
- **自動化**：CI/CDパイプラインに組み込むことで、デプロイ後に自動で負荷テストが実行可能
- **SLA失敗時**：`passFailCriteria`でしきい値を超えるとワークフローが失敗し、品質ゲートとして機能
- **監視連携**：App InsightsやGrafanaと連携し、リアルタイムでパフォーマンス監視も可能
- **テストパターン**：本番・ステージング環境で異なるテストシナリオを設定可能

### 補足Tips
**しきい値（SLA）**を設定して、一定以上のレスポンスタイムやエラー率でジョブを失敗させることも可能
ステージング環境での自動テストに組み込むことで、本番前の品質保証が可能
GrafanaやApp Insightsと連携してリアルタイムモニタリングも可能

- 詳細は[公式ドキュメント](https://learn.microsoft.com/ja-jp/azure/load-testing/)も参照してください。