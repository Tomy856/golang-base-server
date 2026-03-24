Go言語の基本サーバー構成

## 実行方法

### ローカル実行
1. 依存関係をインストール:
   ```bash
   go mod tidy
   ```

2. サーバーを起動:
   ```bash
   go run cmd/main.go
   ```

3. ブラウザで http://localhost:8080 にアクセスすると "Hello World!!" が表示されます。

### Docker Composeでの開発実行
1. `.env` ファイルを生成する（初回のみ）:
   ```bash
   bash scripts/set-env.sh
   ```
   > コンテナをホストユーザーと同じUID/GIDで動かすために必要です。
   > `.env` はgit管理対象外のため、クローン後に必ず実行してください。

2. Docker Composeで起動:
   ```bash
   docker compose up --build
   ```

3. ブラウザで http://localhost:8080 にアクセスすると "Hello World!!" が表示されます。
   - ソースコードの変更が自動で反映されます（ホットリロード）。

4. GoDoc を確認
   - ブラウザで http://localhost:6060 にアクセスすると `godoc` が起動中で API ドキュメントが参照できます。

### Dev Containerでの開発実行（推奨）
1. `.env` ファイルを生成する（初回のみ）:
   ```bash
   bash scripts/set-env.sh
   ```
   > Ubuntu上で実行してください。`.env` はgit管理対象外のため、クローン後に必ず実行してください。

2. VS Codeでこのフォルダを開く。
3. 通知が表示されたら "Reopen in Container" をクリック。
4. 自動的に開発コンテナに入り、Airによるホットリロードが有効になります。
5. ブラウザで http://localhost:8080 にアクセスすると "Hello World!!" が表示されます。

## アーキテクチャ

このプロジェクトはDDD駆動とクリーンアーキテクチャを採用しています。

- Domain: ドメイン層
- Application: アプリケーション層 (ユースケース)
- Infrastructure: インフラ層
- Presentation: プレゼンテーション層 (ハンドラー)
