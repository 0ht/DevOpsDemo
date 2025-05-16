# ステップ6：アプリのデプロイ（Azure Static Web Apps + GitHub Actions + Bicep）

## 目的
- Reactフロントエンド・ExpressバックエンドをAzure Static Web Apps構成でCI/CD自動デプロイ
- Bicepでインフラを管理し、GitHub Actionsで自動デプロイ

## ディレクトリ構成

```
app/
  frontend/   # React (TypeScript)
  backend/    # Express (Node.js)
infra/
  main.bicep  # Static Web Apps用Bicepテンプレート
  main.parameters.json
.github/
  workflows/
    deploy-app.yml  # GitHub Actionsワークフロー
```

## 手順

### ステップ 6-1：インフラ（Static Web Apps）をBicepでデプロイ
1. **パラメータファイルの編集**
   - `infra/main.parameters.json`で必要な値（アプリ名、リージョンなど）を設定します。
   - `location`は`eastasia`や`westeurope`などStatic Web Apps対応リージョンを指定してください。

2. **Bicepデプロイ**
   - PowerShellやターミナルで以下を実行：
     ```pwsh
     az deployment group create \
       --resource-group <リソースグループ名> \
       --template-file infra/main.bicep \
       --parameters @infra/main.parameters.json
     ```
   - デプロイ後、Azure PortalでStatic Web Appsリソースが作成されていることを確認します。

### ステップ 6-2：GitHub Actions ワークフローの作成
1. **Secrets登録**
   - Azure PortalでStatic Web Appsリソースの[APIトークン]から`AZURE_STATIC_WEB_APPS_API_TOKEN`を取得し、GitHubリポジトリのSettings > Secrets and variables > Actionsで登録。
   - Bicepによるインフラ自動デプロイも行う場合、サービスプリンシパル情報（`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`）もSecretsに登録。

2. **ワークフローファイルの作成**
   - `.github/workflows/deploy-app.yml`を作成し、以下のように記述します：
     ```yaml
     name: Azure Static Web Apps CI/CD (with Infra)

     on:
       push:
         branches:
           - main
       workflow_dispatch:

     jobs:
       infra_deploy:
         runs-on: ubuntu-latest
         steps:
           - uses: actions/checkout@v3

           - name: Azure Login
             uses: azure/login@v2
             with:
               client-id: ${{ secrets.ARM_CLIENT_ID }}
               tenant-id: ${{ secrets.ARM_TENANT_ID }}
               subscription-id: ${{ secrets.ARM_SUBSCRIPTION_ID }}
               client-secret: ${{ secrets.ARM_CLIENT_SECRET }}

           - name: Deploy Bicep
             uses: azure/arm-deploy@v2
             with:
               resourceGroupName: <リソースグループ名>
               template: infra/main.bicep
               parameters: infra/main.parameters.json

       build_and_deploy:
         runs-on: ubuntu-latest
         needs: infra_deploy
         steps:
           - uses: actions/checkout@v3

           - name: Setup Node.js
             uses: actions/setup-node@v4
             with:
               node-version: '18'

           - name: Install frontend dependencies
             run: |
               cd app/frontend
               npm ci

           - name: Build frontend
             run: |
               cd app/frontend
               npm run build

           - name: Install backend dependencies
             run: |
               cd app/backend
               npm ci

           - name: Deploy to Azure Static Web Apps
             uses: Azure/static-web-apps-deploy@v1
             with:
               azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
               repo_token: ${{ secrets.GITHUB_TOKEN }}
               action: 'upload'
               app_location: 'app/frontend'
               api_location: 'app/backend'
               output_location: 'build'
     ```
   - `infra_deploy`ジョブでBicepによるインフラ自動デプロイを実施し、完了後にアプリ本体のデプロイを行います。
   - `<リソースグループ名>`はご自身の環境に合わせて修正してください。
   - 必要なSecrets（APIトークン、サービスプリンシパル情報）を事前に登録してください。

### ステップ 6-3：デプロイの確認
1. **GitHub Actionsのログ確認**
   - Actionsタブでワークフローが成功していることを確認します。

2. **Azure Portalでの確認**
   - Static Web Appsリソースの「URL」からアプリにアクセスし、動作を確認します。
   - API（Express）も`/api/`配下で動作することを確認。

### 補足Tips
1. **リージョンエラー時の対応**
   - `japaneast`はStatic Web Apps未対応です。`eastasia`や`westeurope`等を指定してください。

2. **API Tokenの再発行**
   - 必要に応じてAzure PortalからAPIトークンを再発行できます。

3. **Bicepによるインフラ管理**
   - インフラ変更時はBicepテンプレートを修正し、再デプロイしてください。

4. **GitHub Actionsの手動実行**
   - `workflow_dispatch`で手動実行も可能です。

5. **公式ドキュメント**
   - [Azure Static Web Apps ドキュメント](https://learn.microsoft.com/ja-jp/azure/static-web-apps/)
   - [GitHub Actions for Azure Static Web Apps](https://github.com/Azure/static-web-apps-deploy)

---

- 旧App Service構成やサービスプリンシパルは不要です。
- ディレクトリ構成・Bicep・GitHub Actions・API Tokenの管理方法に注意してください。
- 詳細なインフラ構成やパラメータ例は`infra/main.bicep`・`infra/main.parameters.json`を参照。