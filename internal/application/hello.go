// Package application はサービスのアプリケーション層のユースケースを実装します。
package application

type helloUsecase struct{}

// NewHelloUsecase は HelloUsecase の実装を生成します。
func NewHelloUsecase() HelloUsecase {
	return &helloUsecase{}
}

// GetHello はあいさつメッセージを返します。
func (u *helloUsecase) GetHello() (string, error) {
	return "Hello, world!", nil
}
