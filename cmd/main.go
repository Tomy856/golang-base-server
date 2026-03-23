package main

import (
	"golang-base-server/internal/application"
	"golang-base-server/internal/presentation"

	"github.com/gin-gonic/gin"
)

func main() {
	usecase := application.NewHelloUsecase()
	handler := presentation.NewHelloHandler(usecase)

	r := gin.Default()
	r.GET("/", handler.GetHello)
	r.Run()
}