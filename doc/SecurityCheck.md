# ステップ3：GitHub Advanced Securityによるセキュリティチェック

## 目的
コードの品質とセキュリティを自動でチェック
シークレットや脆弱性の早期発見

## 手順

### ステップ 3-1：GitHub Advanced Security を有効化
GitHubリポジトリのトップページを開く
「Settings」→「Security」→「Code security and analysis」へ移動
以下の項目を有効化：
✅ Code scanning
✅ Secret scanning
✅ Dependabot alerts
💡 注意：GHASはGitHub Enterprise Cloudプランで利用可能です。パブリックリポジトリでは一部機能が無料で使えます。

### ステップ 3-2：Code Scanning の設定
「Security」→「Code scanning alerts」→「Set up code scanning」
「Default」または「Advanced（YAMLでカスタム）」を選択
例：github/codeql-action を使ったワークフローを追加

コードをPushすると、自動でスキャンが実行される

### ステップ 3-3：Secret Scanning の確認
GitHubはPushされたコード内にAPIキーやパスワードなどのシークレットが含まれていないかを自動検出
検出された場合、**Securityタブの「Secret scanning alerts」**に表示される
対応方法：
該当シークレットを無効化
.envなどに分離し、.gitignoreで除外

### ステップ 3-4：Dependabot による依存関係の脆弱性チェック
dependabot.yml を .github フォルダに追加

脆弱性がある依存パッケージがあると、自動でPRが作成される
PRをマージすることで安全なバージョンに更新可能
✅ 成果物の確認
Securityタブで以下を確認：
Code scanning alerts
Secret scanning alerts
Dependabot alerts

### 補足Tips
PR作成時に自動スキャンを走らせることで、レビュー前に問題を検出可能
SlackやTeamsと連携してアラート通知も可能
GitHub Actionsと組み合わせてCI/CDに統合するのがベストプラクティス



🔍 追加情報・補足ポイント
1. Code Scanningのカスタムルール
CodeQLはカスタムクエリを作成可能です。
独自のセキュリティポリシーやコーディング規約に基づいたチェックを追加できます。
例：特定のライブラリの使用禁止、ログ出力の形式チェックなど。
2. Secret Scanningの拡張
GitHubは主要なクラウドプロバイダー（AWS, Azure, GCPなど）のシークレットパターンを自動検出します。
カスタムパターンも設定可能（例：社内APIキーの形式など）。
Enterpriseプランでは**プッシュ前スキャン（Push Protection）**も利用可能。
3. セキュリティアラートの自動通知
GitHub ActionsやWebhookを使って、SlackやTeamsにアラートを通知可能。
例：security-events パーミッションを使って、アラートをJSON形式で取得し、通知に活用。
4. セキュリティダッシュボードの活用
Organizationレベルでのセキュリティダッシュボードを使えば、複数リポジトリの状態を一元管理可能。
脆弱性の傾向や未対応のアラートを可視化できます。
5. CI/CDとの統合
Code ScanningやSecret Scanningは、GitHub Actionsのワークフローに組み込むことで、PR作成時に自動チェックが可能。
セキュリティチェックを**ブロッカー（必須チェック）**として設定することで、問題のあるコードのマージを防止できます。
🧪 実践例：PR時にセキュリティチェックを必須にする
リポジトリの「Settings」→「Branches」→「Branch protection rules」を開く
mainブランチに対して以下を設定：
✅ Require status checks to pass before merging
✅ Include CodeQL や Secret Scanning のチェック名を指定
📚 参考リンク（公式ドキュメント）
GitHub Advanced Security Overview
CodeQL Custom Queries
Secret Scanning Patterns



----

以下は、GitHub Actionsを使ってセキュリティチェックをCI/CDパイプラインに統合する例です。
この例では、PR作成時やPush時に自動でCodeQLによるコードスキャンとSecret Scanningを実行し、問題があればマージをブロックする構成になっています。

✅ CI/CD統合例：GitHub Actionsでのセキュリティチェック
📁 ファイル構成（例）
.github/
└── workflows/
    └── security-check.yml
🧾 security-check.yml の内容

🔐 ブランチ保護ルールの設定（GitHub UI）
リポジトリの「Settings」→「Branches」→「Add rule」
対象ブランチ：main
以下を有効化：
✅ Require a pull request before merging
✅ Require status checks to pass before merging
✅ 適用するチェック名に CodeQL Analysis を追加
✅ 結果
PR作成時に自動でセキュリティチェックが実行される
問題がある場合はPRがマージできない
チーム全体でセキュリティ意識を高めながら開発が可能
この構成は、セキュリティをCI/CDの一部として自然に組み込むベストプラクティスです。
必要であれば、Dependabotの自動PR統合やSlack通知の追加も可能です。