# ステップ6：負荷テスト（Azure Load Testing + GitHub Actions）

## 目的
アプリケーションのスケーラビリティと耐久性を検証
CI/CDパイプラインに組み込んで、デプロイ後に自動で負荷テストを実行

## 手順

### ステップ 6-1：Azure Load Testing リソースの作成
Azureポータルで「Azure Load Testing」を検索
「作成」をクリックし、以下を設定：
リソース名：loadtest-demo
リージョン：アプリと同じリージョン
リソースグループ：demo-rg など
作成後、テストプランを作成（例：100ユーザーが30秒間アクセス）

### ステップ 6-2：テストスクリプトの準備（JMeter形式）
loadtest.jmx ファイルを作成（またはAzure Portalで生成）
GitHubリポジトリに loadtest/ フォルダを作成し、スクリプトを配置

### ステップ 6-3：GitHub Actions ワークフローに統合
📁 .github/workflows/loadtest.yml

🔐 必要なSecrets：

AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID

### ステップ 6-4：結果の確認
GitHub Actionsのログにテスト結果が表示される
Azure Portalの「Load Testing」から詳細なレポート（レスポンスタイム、エラー率、スループットなど）を確認可能

### 補足Tips
**しきい値（SLA）**を設定して、一定以上のレスポンスタイムやエラー率でジョブを失敗させることも可能
ステージング環境での自動テストに組み込むことで、本番前の品質保証が可能
GrafanaやApp Insightsと連携してリアルタイムモニタリングも可能