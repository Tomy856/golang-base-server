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
1. Docker Composeで起動:
   ```bash
   docker-compose up --build
   ```

2. ブラウザで http://localhost:8080 にアクセスすると "Hello World!!" が表示されます。
   - ソースコードの変更が自動で反映されます（ホットリロード）。

### Dev Containerでの開発実行（推奨）
1. VS Codeでこのフォルダを開く。
2. 通知が表示されたら "Reopen in Container" をクリック。
3. 自動的に開発コンテナに入り、Airによるホットリロードが有効になります。
4. ブラウザで http://localhost:8080 にアクセスすると "Hello World!!" が表示されます。

## アーキテクチャ

このプロジェクトはDDD駆動とクリーンアーキテクチャを採用しています。

- Domain: ドメイン層
- Application: アプリケーション層 (ユースケース)
- Infrastructure: インフラ層
- Presentation: プレゼンテーション層 (ハンドラー)