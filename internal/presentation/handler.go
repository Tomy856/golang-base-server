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

// ChatRequest は POST /api/chat のリクエストボディ構造です。
type ChatRequest struct {
	Message   string `json:"message" binding:"required,min=1,max=2000"`
	SessionID string `json:"session_id" binding:"required,uuid"`
}

// ChatResponse は POST /api/chat のレスポンスボディ構造です。
type ChatResponse struct {
	Reply        string  `json:"reply"`
	Status       string  `json:"status"`
	ErrorMessage *string `json:"error_message"`
}

// ChatHandler はチャットAPIのルート処理を行います。
type ChatHandler struct {
	usecase application.ChatUsecase
}

// NewChatHandler は ChatHandler を生成します。
func NewChatHandler(usecase application.ChatUsecase) *ChatHandler {
	return &ChatHandler{usecase: usecase}
}

// PostChat は /api/chat を処理します。
func (h *ChatHandler) PostChat(c *gin.Context) {
	var req ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		infrastructure.LogError(err)
		msg := "invalid request body"
		c.JSON(http.StatusBadRequest, ChatResponse{Reply: "", Status: "error", ErrorMessage: &msg})
		return
	}

	reply, err := h.usecase.Chat(c.Request.Context(), req.Message, req.SessionID)
	if err != nil {
		infrastructure.LogError(err)
		msg := "AI processing failed"
		c.JSON(http.StatusInternalServerError, ChatResponse{Reply: "", Status: "error", ErrorMessage: &msg})
		return
	}

	c.JSON(http.StatusOK, ChatResponse{Reply: reply, Status: "success", ErrorMessage: nil})
}
