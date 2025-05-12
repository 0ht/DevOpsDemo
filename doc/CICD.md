# 🚀 ステップ5：アプリのデプロイ（Azure App Service + GitHub Actions）

## 🎯 目的
アプリケーションをCI/CDパイプラインでAzureに自動デプロイ
Bicepで構成したApp Serviceにアプリを反映

## 手順

### ステップ 5-1：アプリケーションの準備
アプリケーションコードを作成

例：Node.js, Python Flask, .NET, Next.js など
package.json / requirements.txt / csproj などを整備

azure-webapps-deploy に対応した構成にする

ルートに startup ファイルや web.config があるとベター

### ステップ 5-2：GitHub Actions ワークフローの作成
📁 .github/workflows/deploy-app.yml

🔐 必要なSecrets：

AZURE_WEBAPP_PUBLISH_PROFILE：Azure PortalのApp Service → 「発行プロファイルの取得」からダウンロードし、GitHubに登録

### ステップ 5-3：デプロイの確認
GitHub Actionsのログでデプロイ成功を確認
Azure PortalでApp Serviceにアクセスし、アプリが反映されているか確認

### 補足Tips
ステージングスロットを使えば、Blue/Greenデプロイも可能
GitHub Environmentsを使って、環境ごとに承認フローを追加可能
アプリのヘルスチェックを組み込むことで、デプロイ後の自動検証も可能