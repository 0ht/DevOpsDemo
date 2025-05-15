# ステップ6：アプリのデプロイ（Azure App Service + GitHub Actions）

## 目的
- アプリケーションをCI/CDパイプラインでAzureに自動デプロイ
- Bicepで構成したApp Serviceにアプリを反映

## 手順

### ステップ 6-1：アプリケーションの準備
1. **アプリケーションコードの作成**:
   - Node.js、Python Flask、.NET、Next.jsなど、使用するフレームワークに応じたコードを作成します。
   - 必要に応じて以下のファイルを整備します：
     - `package.json`（Node.jsの場合）
     - `requirements.txt`（Pythonの場合）
     - `.csproj`（.NETの場合）
   - ルートディレクトリに以下のファイルを配置すると、デプロイがスムーズになります：
     - `startup`ファイル
     - `web.config`（必要に応じて）

2. **Azure App Serviceに対応した構成**:
   - 以下の点を確認してください：
     1. **アプリケーションのルート構成**
        - デプロイ対象のアプリケーションがリポジトリのルート、またはデプロイコマンドで指定したディレクトリに存在していること。
     2. **ビルド・起動ファイルの有無**
        - Node.jsの場合：`package.json`が存在し、`start`スクリプトが定義されていること。
        - ReactやNext.jsなどのフロントエンドの場合：`build`ディレクトリが生成されていること。
        - Pythonの場合：`requirements.txt`や`startup`ファイルがあること。
        - .NETの場合：`.csproj`や`web.config`があること。
     3. **ビルド成果物の配置**
        - ビルドが必要な場合（例：React）は、`npm run build`で`build/`ディレクトリが生成されていること。
     4. **Webアプリの種類に応じた追加設定**
        - Linux/Windows App Serviceの違いに注意（Node.jsはLinux推奨）。
        - 必要に応じて`web.config`や`startup`ファイルを用意。
     5. **公式ドキュメントの参照**
        - [Azure App Service デプロイのベストプラクティス](https://learn.microsoft.com/ja-jp/azure/app-service/deploy-best-practices)
        - [az webapp deploy 公式ドキュメント](https://learn.microsoft.com/ja-jp/cli/azure/webapp#az-webapp-deploy)

   これらを満たしていれば、GitHub Actionsからの自動デプロイが可能です。

### ステップ 6-2：GitHub Actions ワークフローの作成（2アプリ対応例・発行プロファイル不要）
1. **ワークフローファイルの作成**:
   - `.github/workflows/deploy-app.yml`を作成します。
   - backend（API）とnote-taking-app（フロントエンド）の2つのApp Serviceへサービスプリンシパル認証＋zipデプロイでデプロイする例：
     ```yaml
     name: Deploy Applications

     on:
       push:
         branches:
           - main

     jobs:
       build-and-deploy-backend:
         runs-on: ubuntu-latest
         steps:
           - name: Checkout code
             uses: actions/checkout@v3

           - name: Set up Node.js
             uses: actions/setup-node@v4
             with:
               node-version: '18'

           - name: Install dependencies (backend)
             run: |
               cd backend
               npm ci

           - name: Zip backend
             run: |
               cd backend
               zip -r ../backend.zip .

           - name: Azure Login
             uses: azure/login@v1
             with:
               creds: ${{ secrets.AZURE_CREDENTIALS }}

           - name: Deploy backend to Azure Web App
             run: |
               az webapp deploy --resource-group <backend-rg> --name <backend-app-name> --src-path backend.zip --type zip

       build-and-deploy-frontend:
         runs-on: ubuntu-latest
         needs: build-and-deploy-backend
         steps:
           - name: Checkout code
             uses: actions/checkout@v3

           - name: Set up Node.js
             uses: actions/setup-node@v4
             with:
               node-version: '18'

           - name: Install dependencies (frontend)
             run: |
               cd note-taking-app
               npm ci
               npm run build

           - name: Zip frontend build
             run: |
               cd note-taking-app/build
               zip -r ../../frontend.zip .

           - name: Azure Login
             uses: azure/login@v1
             with:
               creds: ${{ secrets.AZURE_CREDENTIALS }}

           - name: Deploy frontend to Azure Web App
             run: |
               az webapp deploy --resource-group <frontend-rg> --name <frontend-app-name> --src-path frontend.zip --type zip
     ```

2. **Secretsの設定**:
   - サービスプリンシパルを作成し、`AZURE_CREDENTIALS`（JSON形式）と`AZURE_SUBSCRIPTION_ID`をGitHubリポジトリのSecretsに登録します。

### サービスプリンシパルの再利用について
- サービスプリンシパルは「05Infradeploy.md」の手順で作成済みのものを再利用します。
- 追加で作成する必要はありません。
- 既存のサービスプリンシパル情報（`AZURE_CREDENTIALS`）と`AZURE_SUBSCRIPTION_ID`をGitHubリポジトリのSecretsに登録してください。
- Secretsの登録方法やJSON形式は「05Infradeploy.md」の内容を参照してください。

### ステップ 6-3：デプロイの確認
1. **GitHub Actionsのログ確認**:
   - GitHub Actionsの実行ログで、両方のデプロイが成功したことを確認します。

2. **Azure Portalでの確認**:
   - Azure Portalにアクセスし、両方のApp Serviceが正しくデプロイされていることを確認します。
   - それぞれのアプリケーションのURLにアクセスして、動作を確認します。

### 補足Tips
1. **ステージングスロットの活用**:
   - Blue/Greenデプロイを実現するために、ステージングスロットを使用します。
   - スロット間でトラフィックをスワップすることで、ダウンタイムを最小限に抑えます。

2. **GitHub Environmentsの使用**:
   - 環境ごとに承認フローを追加し、デプロイの安全性を向上させます。

3. **ヘルスチェックの組み込み**:
   - アプリケーションのヘルスチェックを自動化し、デプロイ後の検証を効率化します。

- 2つのApp ServiceでSecretsを分けて管理することで、セキュリティと運用性が向上します。
- 必要に応じて、`needs`でデプロイ順序を制御できます（例：API→フロントエンド）。
- Blue/GreenデプロイやGitHub Environmentsも同様に2アプリで活用可能です。