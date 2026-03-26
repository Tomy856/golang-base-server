# 技術スタック：実装・スタイルガイド

## 1. 命名規則とスタイル
- **変数 / 関数**: `camelCase`（例: `getUserData`）
- **型 / インターフェース**: `PascalCase`（例: `UserResponse`） ※`I`プレフィックス（`IUser`等）は禁止。
- **ファイル命名**:
    - フロントエンド/コンポーネント: `kebab-case`（例: `chat-form.html`）
    - Goソースファイル: `snake_case`（例: `handler_func.go`）
- **定数**: `SCREAMING_SNAKE_CASE`（例: `MAX_RETRY_COUNT`）
- **コメント**:
    - 全て**日本語**で行うこと。
    - 関数・構造体の上には必ず内容を説明するドキュメンテーションコメントを記述せよ。

## 2. コア技術
- **Server**: Go (Gin), GORM
- **Infrastructure**: Docker (WSL2/Rancher Desktop), PostgreSQL
- **Tools**: Obsidian (Mermaid), dbdiagram.io