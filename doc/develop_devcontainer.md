# ステップ2：開発環境の整備（所要時間：約5分）

## 目的
- Dev Containersを使って開発環境を整備する
- GitHub Copilotを活用してアプリケーションの開発を行う

https://learn.microsoft.com/ja-jp/azure/dev-box/overview-what-is-microsoft-dev-box

## Dev Containersとは？
Dev Containersは、Visual Studio Codeを使用して開発環境をコンテナ化するための機能です。これにより、開発者は特定のプロジェクトに必要な依存関係やツールを簡単に管理できるようになります。Dev Containersは、Dockerを使用してコンテナを作成し、その中でアプリケーションを開発します。

### Dev Containersの利点
- 必要なFeatureやExtensionを設定ファイルに記述するため、一貫した開発環境を提供
- 環境のセットアップが簡単
- プロジェクトごとに異なる依存関係を管理可能
- 設定ファイルを共有することでチームメンバー間での環境の共有が容易

### 前提条件
- Docker Desktop がインストールされていること（ローカル開発の場合）
- Visual Studio Code がインストールされていること
- VSCode 拡張機能「Dev Containers」がインストールされていること

## 手順

### ステップ 2-1：Dev Containers を使った開発環境の構築手順

1. リポジトリに .devcontainer ディレクトリを作成
   1. プロジェクトルートに .devcontainer/ フォルダを作成
   2. 以下の2ファイルを作成
   - .devcontainer/devcontainer.json

2. VSCode で Dev Container を起動
   1. VSCode でプロジェクトを開く
   2. コマンドパレット（Ctrl+Shift+P）を開き、「Dev Containers: Reopen in Container」を選択
   3. 初回起動時に Docker イメージのビルドと依存関係のインストールが行われる
   4. コンテナ内で VSCode が再起動し、開発環境が整った状態になる

### ステップ 2-2：VSCodeのセットアップ

1. 必要な拡張機能がインストールされている事を確認
   - devcontainers.jsonに定義されている以下の機能が有効化されている事を確認
      - Azure CLI Tools
      - Azure Resources
      - Docker
      - ESLint
      - GitHub Copilot

2. GitHub Copilot を有効化
   1. VSCode の拡張機能で「GitHub Copilot」が有効になっていることを確認
   2. GitHub アカウントでサインイン
   3. エディタ上でコメントを入力し、Copilot の補完が動作することを確認

## 補足情報
- Dev Container は GitHub Codespaces でも同じ構成で動作します
- チームで .devcontainer を共有することで、環境差異をなくせます
- 複数言語やツールチェーンを含む複雑な環境も定義可能です