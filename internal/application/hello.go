package application

type helloUsecase struct{}

func NewHelloUsecase() HelloUsecase {
	return &helloUsecase{}
}

func (u *helloUsecase) GetHello() string {
	return "Hello World!!"
}