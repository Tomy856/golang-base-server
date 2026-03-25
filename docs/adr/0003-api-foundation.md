# ADR: API and UI Foundation for Chat Interface
- **日付**: 2026-03-25
- **ステータス**: Decided
- **関連チケット**: 0003
- **対象BDD**: server/features/0003-ai-interface-abstraction/01-api-foundation.feature, 02-ui-foundation.feature

## 背景
AIインターフェースの抽象化の第一歩として、POST /api/chat エンドポイントを実装。フロントエンドからJSONリクエストを受け取り、レスポンスを返す基盤を構築。message (1-2000文字) と session_id (UUID) のバリデーションを行い、固定レスポンスを返す。さらに、静的ファイル配信とHTMLテンプレートによるUI基盤を構築。

## 採用した設計（Go Interface/Func）
```go
type ChatUsecase interface {
    Chat(ctx context.Context, message string, sessionID string) (string, error)
}

type ChatRequest struct {
    Message   string `json:"message" binding:"required,min=1,max=2000"`
    SessionID string `json:"session_id" binding:"required,uuid"`
}

type ChatResponse struct {
    Reply        string  `json:"reply"`
    Status       string  `json:"status"`
    ErrorMessage *string `json:"error_message"`
}

func (h *ChatHandler) PostChat(c *gin.Context)

// Gin Static File Serving
r.Static("/static", "./static")
r.LoadHTMLGlob("templates/*")
```

## 既存機能の再利用（検出結果）
- internal/application/hello.go の構造を参考にUsecase層を拡張
- internal/infrastructure/logger.go のLogErrorを再利用
- 既存のPostChatハンドラーをUIから疎通

## 却下された代替案
- なし（推測禁止の原則により、既存資産のみを使用）

## Test Evidence
- Total Coverage: 85%