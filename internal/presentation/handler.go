// Package presentation は API エンドポイントの HTTP ハンドラーを提供します。
package presentation

import (
	"net/http"

	"golang-base-server/internal/application"
	"golang-base-server/internal/infrastructure"

	"github.com/gin-gonic/gin"
)

// HelloHandler はあいさつルートを処理します。
type HelloHandler struct {
	usecase application.HelloUsecase
}

// NewHelloHandler は提供されたユースケースで新しい HelloHandler を生成します。
func NewHelloHandler(usecase application.HelloUsecase) *HelloHandler {
	return &HelloHandler{usecase: usecase}
}

// GetHello は GET / に対する HTTP ハンドラーで、あいさつレスポンスを返します。
func (h *HelloHandler) GetHello(c *gin.Context) {
	message, err := h.usecase.GetHello()
	if err != nil {
		infrastructure.LogError(err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
		return
	}
	c.String(http.StatusOK, message)
}
