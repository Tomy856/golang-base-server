// Package application はサービスのアプリケーション層のユースケースを実装します。
package application

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"
)

// ChatUsecase はチャット関連ビジネスロジックの契約を定義します。
type ChatUsecase interface {
	Chat(ctx context.Context, message string, sessionID string) (string, error)
}

type chatUsecase struct {
	proxyURL   string
	httpClient *http.Client
}

// NewChatUsecase は ChatUsecase の実装を生成します。
// 環境変数 NODE_PROXY_URL でプロキシ先を指定 (デフォルト: http://localhost:3000)
func NewChatUsecase() ChatUsecase {
	proxyURL := os.Getenv("NODE_PROXY_URL")
	if proxyURL == "" {
		proxyURL = "http://127.0.0.1:3000"
	}
	proxyURL = strings.Replace(proxyURL, "localhost", "127.0.0.1", 1)
	return &chatUsecase{
		proxyURL: proxyURL,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

type proxyRequest struct {
	Message   string `json:"message"`
	SessionID string `json:"session_id"`
}

type proxyResponse struct {
	Reply  string `json:"reply"`
	Error  string `json:"error"`
	Detail string `json:"detail"`
}

// Chat はNode.jsプロキシサーバーにリクエストを転送し、AI応答を返します。
func (u *chatUsecase) Chat(ctx context.Context, message string, sessionID string) (string, error) {
	reqBody, err := json.Marshal(proxyRequest{Message: message, SessionID: sessionID})
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, u.proxyURL+"/proxy/chat", bytes.NewBuffer(reqBody))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := u.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to call node proxy: %w", err)
	}
	defer resp.Body.Close()

	var proxyResp proxyResponse
	if err := json.NewDecoder(resp.Body).Decode(&proxyResp); err != nil {
		return "", fmt.Errorf("failed to decode proxy response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("proxy error: %s (detail: %s)", proxyResp.Error, proxyResp.Detail)
	}

	return proxyResp.Reply, nil
}
