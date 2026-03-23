package application

type HelloUsecase interface {
	GetHello() (string, error)
}
