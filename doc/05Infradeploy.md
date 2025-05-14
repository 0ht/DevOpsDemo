# ステップ5：インフラ構成（Bicep）

## 目的
- アプリケーションが稼働するAzure環境を構築
- Azureリソースを**Infrastructure as Code（IaC）**で管理
- GitHub Actionsと連携して自動デプロイを実現

### Bicepファイルのベストプラクティス

- **モジュール化**: 複数のBicepファイルに分割し、再利用性を高める。
  - 例: `network.bicep`, `storage.bicep`, `appservice.bicep` など。
- **パラメータファイルの活用**: 環境ごとに異なる値を管理するために、`main.parameters.json` を使用。
  - 例: `dev.parameters.json`, `prod.parameters.json`
- **環境ごとの分離**: dev, staging, prod などの環境で異なるリソースをデプロイする。
  - GitHub Environments を活用して承認フローを追加可能。


## 手順

### ステップ 5-1：Bicepの準備

環境準備
（以下を実施するが、今回はdevcontainerで定義済みのため芙蓉）

1. ローカルまたはDevBoxにBicep CLIをインストール
    ```bash
    az bicep install
   ```
2. Azure CLIを最新バージョンに更新
    ```bash
    az upgrade
    ```  
### ステップ 5-2：Bicepファイルを作成
  - 必要なファイルは **github copilot agent** が生成済み
    - `main.bicep` と `main.parameters.json` を作成済み 
    - Azureリソースを定義
    - 必要なパラメータを設定

### ステップ 5-3：GitHub ActionsでBicepをデプロイ

#### 準備手順
1. .github/workflows/deploy-infra.yml を作成（これも Copilot Agentが作成済み！）

2. 必要なSecrets（GitHubリポジトリのSettings → Secrets and variables）をGithubに登録
  1. サービスプリンシパルの作成
   ```bash
    az ad sp create-for-rbac --name "github-actions-deploy" --role contributor \
    --scopes /subscriptions/02bd8675-0a2c-4ff5-9087-2b3efcf57cd5/resourceGroups/rg-devops
    ```
  2. 出力されるJSONをメモ
   ```json
   {
     "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "displayName": "github-actions-deploy",
     "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```
  3．上記のJSONをそのままGitHub Secretsに登録するために、以下のように整形
    - appId	→ clientId
    - password → clientSecret
    - 手動で追加	subscriptionId
    - tenant → tenantId
   ```json
   {
     "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```  

  3. GitHub Secretsに以下の情報を登録
   - 「Settings」 →「Secrets and variables」→「Actions」→「New repository secret」 をクリック
   - 以下の情報を登録
     - `AZURE_CREDENTIALS`: 上記のJSONをそのまま貼り付け
     - `AZURE_SUBSCRIPTION_ID`: AzureサブスクリプションID（例: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`）

#### デプロイ実施
1. GitHub Actionsをトリガーするために、main.bicepおよびmain.parameters.jsonをGitHubリポジトリにプッシュ
2. GitHub Actionsが自動でトリガーされ、Bicepファイルをデプロイ

### ステップ 5-4：デプロイ後の確認

- **Azure Portalでの確認**:
  - デプロイされたリソースが正しく作成されているか確認。
  - リソースグループ内のリソース一覧を確認。
- **GitHub Actionsログの確認**:
  - デプロイジョブが成功したかを確認。
  - エラーが発生した場合は、ログを詳細に確認して原因を特定。
