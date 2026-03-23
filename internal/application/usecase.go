// Package application はサービスのアプリケーション層のユースケースを実装します。
package application

// HelloUsecase はあいさつ関連のビジネスルールの契約を定義します。
type HelloUsecase interface {
	// GetHello はあいさつメッセージまたはエラーを返します。
	GetHello() (string, error)
}
