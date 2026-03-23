package application

import "errors"

type helloUsecase struct{}

func NewHelloUsecase() HelloUsecase {
	return &helloUsecase{}
}

func (u *helloUsecase) GetHello() (string, error) {
	// Simulate an error for demonstration
	return "", errors.New("simulated error")
}
