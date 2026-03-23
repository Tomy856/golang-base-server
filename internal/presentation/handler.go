package presentation

import (
	"net/http"

	"golang-base-server/internal/application"
	"golang-base-server/internal/infrastructure"

	"github.com/gin-gonic/gin"
)

type HelloHandler struct {
	usecase application.HelloUsecase
}

func NewHelloHandler(usecase application.HelloUsecase) *HelloHandler {
	return &HelloHandler{usecase: usecase}
}

func (h *HelloHandler) GetHello(c *gin.Context) {
	message, err := h.usecase.GetHello()
	if err != nil {
		infrastructure.LogError(err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
		return
	}
	c.String(http.StatusOK, message)
}
