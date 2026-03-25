package tests

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"golang-base-server/internal/application"
	"golang-base-server/internal/presentation"
	"github.com/gin-gonic/gin"
)

func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.POST("/api/chat", presentation.NewChatHandler(application.NewChatUsecase()).PostChat)
	return r
}

func TestChatAPI_PostChat_Success(t *testing.T) {
	r := setupRouter()
	server := httptest.NewServer(r)
	defer server.Close()

	payload := map[string]string{
		"message":    "こんにちは",
		"session_id": "550e8400-e29b-41d4-a716-446655440000",
	}
	body, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("marshal request body: %v", err)
	}

	resp, err := http.Post(server.URL+"/api/chat", "application/json", bytes.NewReader(body))
	if err != nil {
		t.Fatalf("post request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	respData, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read response: %v", err)
	}

	var got struct {
		Reply        string  `json:"reply"`
		Status       string  `json:"status"`
		ErrorMessage *string `json:"error_message"`
	}
	if err := json.Unmarshal(respData, &got); err != nil {
		t.Fatalf("unmarshal response: %v", err)
	}

	if got.Reply != "API base is ready" {
		t.Fatalf("expected reply API base is ready, got %s", got.Reply)
	}
	if got.Status != "success" {
		t.Fatalf("expected status success, got %s", got.Status)
	}
	if got.ErrorMessage != nil {
		t.Fatalf("expected error_message nil, got %v", *got.ErrorMessage)
	}
}

func TestChatAPI_PostChat_ValidationError(t *testing.T) {
	r := setupRouter()
	server := httptest.NewServer(r)
	defer server.Close()

	payload := map[string]string{
		"message":    "",
		"session_id": "invalid-uuid",
	}
	body, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("marshal request body: %v", err)
	}

	resp, err := http.Post(server.URL+"/api/chat", "application/json", bytes.NewReader(body))
	if err != nil {
		t.Fatalf("post request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("expected status 400, got %d", resp.StatusCode)
	}
}
