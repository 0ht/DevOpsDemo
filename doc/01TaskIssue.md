# ステップ1：計画フェーズの詳細手順

## 目的
プロジェクトのタスクを可視化・管理する
開発の進捗をGitHub上で一元管理する

## 手順

### ステップ 1-1：GitHub Projectsの作成
1. GitHubで対象のリポジトリを開く
2. 上部メニューから「Projects」タブをクリック
3. 「New project」をクリック
   - 以下のように設定：
     - Project name：DevOps Demo
     - Template：Board（カンバン形式）
     - Visibility：Private または Public（用途に応じて）
4.「Create」をクリック

### ステップ 1-2：カラム（列）の設定
1. デフォルトで To do / In progress / Done の3列があることを確認
2. 必要に応じてカラムを追加・名前変更（例：Backlog, Review など）

### ステップ 1-3：Issueの作成と登録
1. リポジトリの「Issues」タブを開く
2. 「New issue」をクリック
    - 以下のように記入：
        - Title：アプリの初期構築
        - Description：VSCode + Copilotを使ってアプリの雛形を作成する
        - 必要に応じてラベル（enhancement, dev, など）を追加
        - Assignees：自分またはチームメンバーを選択
3. 「Create」をクリック

### ステップ 1-4：IssueをProjectに追加
1. 作成したIssueを開く
2. 右側の「Projects」セクションで「+ Add to project」をクリック
3. 先ほど作成した DevOps Demo プロジェクトを選択、Statusを「To do」に設定
4. 「Add」をクリック
5. IssueがProjectボードの「To do」列に追加されていることを確認
   
### ステップ 1-5：タスクの進捗管理
1. 開発が始まったら、Projectボード上でIssueカードを「In progress」へドラッグ
2. 完了したら「Done」へ移動、チームで進捗を共有しやすくなる

### 補足Tips
Milestones を使えば、リリース単位でIssueをまとめられます
Automation を使えば、Issueの状態に応じて自動でカラム移動も可能です（例：PRがマージされたら「Done」へ）