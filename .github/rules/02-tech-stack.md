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

## 技術スタック・実装ルール
- **言語**: Go (Gin framework), Node.js
- **Server**: GORM
- **Infrastructure**: Docker (WSL2/Rancher Desktop)
- **Tools**: Obsidian (Mermaid), dbdiagram.io
- **アーキテクチャ**: DDD駆動とクリーンアーキテクチャ。
- **Error Handling**: `fmt.Errorf` によるラッピングを必須とする。
- **Context**: 外部通信を伴う関数には必ず `context.Context` を第一引数に含めること。
