package presentation

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"golang-base-server/internal/application"
)

type HelloHandler struct {
	usecase application.HelloUsecase
}

func NewHelloHandler(usecase application.HelloUsecase) *HelloHandler {
	return &HelloHandler{usecase: usecase}
}

func (h *HelloHandler) GetHello(c *gin.Context) {
	message := h.usecase.GetHello()
	c.String(http.StatusOK, message)
}