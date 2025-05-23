# DevOpsDemo

以下の一連のDevOpsのライフサイクルをデモする手順（GitHub + Azure + Bicep + VSCode + Copilot）です。

## [1. 計画フェーズ（5分）](doc/01TaskIssue.md)
- タスク・Issue管理
  - GitHub Projectsでプロジェクトボードを作成（To Do / In Progress / Done）
  - GitHub I]]suesでタスクを登録し、Projectsと連携
  - 実際にIssueを作成し、Projectに追加するデモ

## 2. 開発環境の整備（5分）
- DevBoxで開発端末を用意
  - [Azure DevBoxで開発用VMを起動](doc/02-1develop_devbox.md)
  - [Dev Containersを使って開発環境を整備する](doc/02-2develop_devcontainer.md)

## [3. GitHub Copilotを使った開発](doc/03develop_app.md)
- VSCodeで新しいアプリ（例：簡単なWeb API）を作成
- Agent Codingでコードを生成する様子をデモ

## [4. セキュリティチェック（3分）](doc/04SecurityCheck.md)
- GitHub Advanced Securityの活用
  - Push後にCode ScanningやSecret Scanningが自動で走る様子を紹介
  - 脆弱性が検出された場合のアラート表示を確認

## [5. インフラ構成（5分）](doc/05Infradeploy.md)
- BicepでIaC
  - Azureリソース（Static Web Apps, Storage, etc.）をBicepで定義
  - GitHubリポジトリにBicepファイルを配置

## [6. CI/CDパイプライン（10分）](doc/06CICD.md)
- GitHub Actionsで自動デプロイ
  - Pushをトリガーに以下を実行
    - BicepでAzureリソースをデプロイ
    - アプリケーションをビルドしてStatic Web Appsにデプロイ
  - 実際にActionsのログを見せながら流れを説明

## [7. 負荷テスト（5分）](doc/07LoadTest.md)
- Load Testingの組み込み
  - GitHub ActionsにAzure Load Testingのステップを追加可能
  - テストシナリオ（例：100ユーザーが同時アクセス）を実行
  - 結果をGitHub ActionsのログやAzure Portalで確認

## 8. まとめ・質疑応答（5分）
- DevOpsの一連の流れを振り返り
  

