// Package application はサービスのアプリケーション層のユースケースを実装します。
package application

import "errors"

type helloUsecase struct{}

// NewHelloUsecase は HelloUsecase の実装を生成します。
func NewHelloUsecase() HelloUsecase {
	return &helloUsecase{}
}

// GetHello はあいさつメッセージを返します（現在はシミュレーション上のエラーを返します）。
func (u *helloUsecase) GetHello() (string, error) {
	// Simulate an error for demonstration
	return "", errors.New("simulated error")
}
