// Package application はサービスのアプリケーション層のユースケースを実装します。
package application

import "context"

// ChatUsecase はチャット関連ビジネスロジックの契約を定義します。
type ChatUsecase interface {
	Chat(ctx context.Context, message string, sessionID string) (string, error)
}

type chatUsecase struct{}

// NewChatUsecase は ChatUsecase の実装を生成します。
func NewChatUsecase() ChatUsecase {
	return &chatUsecase{}
}

// Chat は現状モック応答を返します。
func (u *chatUsecase) Chat(ctx context.Context, message string, sessionID string) (string, error) {
	return "API base is ready", nil
}
