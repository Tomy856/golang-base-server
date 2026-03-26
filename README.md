Go言語のAIチャットサーバー構成

## 概要

このプロジェクトは、AIインターフェースの抽象化を目指したGo言語ベースのサーバーです。GeminiやBedrockなどのAIサービスと統合し、クライアントが統一されたインターフェースでAIと対話できる基盤を提供します。DDD（Domain-Driven Design）とクリーンアーキテクチャを採用しています。

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

3. ブラウザで http://localhost:8080 にアクセスすると、AIチャットインターフェースが表示されます。
   - ルートは `GET /` でテンプレート `index.html` を返し、内部で `Hello, world!!` を生成するユースケースを使っています。

### Docker Composeでの開発実行
1. Docker Composeで起動:
   ```bash
   docker compose up --build
   ```

2. ブラウザで http://localhost:8080 にアクセスすると、AIチャット画面が表示されます。
   - ソースコードの変更が自動で反映されます（ホットリロード）。

3. GoDoc を確認
   - ブラウザで http://localhost:6060 にアクセスすると `godoc` が起動中で API ドキュメントが参照できます。

### Dev Containerでの開発実行（推奨）
1. VS Codeでこのフォルダを開く。
2. 通知が表示されたら "Reopen in Container" をクリック。
3. 自動的に開発コンテナに入り、Airによるホットリロードが有効になります。
4. ブラウザで http://localhost:8080 にアクセスすると、AIチャット画面が表示されます。

## テスト実行

プロジェクトのテストを実行するには、以下のスクリプトを使用します：

```bash
./scripts/run-tests.sh
```

または、手動で：

```bash
go test ./...
```

## API 仕様
- GET /
  - HTMLテンプレートを返却します (index.html, `message: Hello, world!!`).
- POST /api/chat
  - JSONリクエスト: `message`, `session_id` (UUID)
  - JSONレスポンス: `reply`, `status`, `error_message`

## アーキテクチャ

このプロジェクトはDDD駆動とクリーンアーキテクチャを採用しています。

- Domain: ドメイン層
- Application: アプリケーション層 (ユースケース)
- Infrastructure: インフラ層
- Presentation: プレゼンテーション層 (ハンドラー)

## ドキュメント

- [システムアーキテクチャ](docs/System_Architecture.md)
- [ADR (Architecture Decision Records)](docs/adr/README.md)
- [ダイアグラム](docs/diagrams/)
- [BDDシナリオ](server/features/0003-ai-interface-abstraction/)

## 技術スタック

- Go 1.21
- Gin Web Framework
- Docker & Docker Compose
- HTML/CSS/JavaScript (Vanilla JS)
