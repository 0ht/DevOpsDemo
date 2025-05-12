# ステップ4：インフラ構成（Bicep）

## 目的
Azureリソースを**Infrastructure as Code（IaC）**で管理
GitHub Actionsと連携して自動デプロイを実現

## 手順

### ステップ 4-1：Bicepの準備
ローカルまたはDevBoxにBicep CLIをインストール
    
    ```bash
    az bicep install
    ```
    
Bicepファイルを作成（例：main.bicep）



パラメータファイル（任意）を作成
main.parameters.json などで環境ごとの値を管理可能

### ステップ 4-2：Bicepファイルの検証とビルド

Bicepファイルの検証

```bash
az bicep build --file main.bicep
```

BicepファイルをARMテンプレートに変換

```bash
az bicep export template --file main.bicep --output json
```

```
bicep build main.bicep  # ARMテンプレートに変換
az deployment group validate \
  --resource-group <your-rg> \
  --template-file main.bicep
```

### ステップ 4-3：GitHub ActionsでBicepをデプロイ
📁 .github/workflows/deploy-infra.yml

🔐 必要なSecrets（GitHubリポジトリのSettings → Secrets and variables）：

AZURE_CREDENTIALS：az ad sp create-for-rbac で取得
AZURE_SUBSCRIPTION_ID

### ステップ 4-4：デプロイの確認
GitHub Actionsのログでデプロイ状況を確認
Azure Portalでリソースが作成されていることを確認

###💡 補足Tips
モジュール化：複数のBicepファイルに分割して再利用性を高める
環境分離：dev, staging, prod などでパラメータを切り替える
GitHub Environments を使って環境ごとの承認フローを追加可能