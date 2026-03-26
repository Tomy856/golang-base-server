package tests

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
)

func setupUIRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.LoadHTMLGlob("../templates/*")
	r.Static("/static", "../static")
	// ハンドラー構造体を介さず、直接 index.html を返す
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{
			"message": "Hello World!", // テストが既存のメッセージを検証している場合は残す
		})
	})
	return r
}

func TestUI_IndexHTML_Renders(t *testing.T) {
	r := setupUIRouter()
	server := httptest.NewServer(r)
	defer server.Close()

	resp, err := http.Get(server.URL + "/")
	if err != nil {
		t.Fatalf("get request failed: %v", err)
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	bodyStr := string(body)

	// 新しいデザイン基準のIDチェック
	expectedIDs := []string{"id=\"chat\"", "id=\"message\"", "id=\"send\"", "id=\"activeAgentsList\""}
	for _, id := range expectedIDs {
		if !strings.Contains(bodyStr, id) {
			t.Errorf("missing critical UI element: %s", id)
		}
	}

	if !strings.Contains(bodyStr, "/static/js/chat.js") {
		t.Error("response does not contain chat.js script")
	}
}

func TestUI_ChatJS_Serves(t *testing.T) {
	r := setupUIRouter()
	server := httptest.NewServer(r)
	defer server.Close()

	resp, err := http.Get(server.URL + "/static/js/chat.js")
	if err != nil {
		t.Fatalf("get request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read response: %v", err)
	}

	bodyStr := string(body)
	if !strings.Contains(bodyStr, "sendMessage") {
		t.Error("chat.js does not contain sendMessage function")
	}
	if !strings.Contains(bodyStr, "generateUUID") {
		t.Error("chat.js does not contain generateUUID function")
	}
	if strings.Contains(bodyStr, "jQuery") || strings.Contains(bodyStr, "React") || strings.Contains(bodyStr, "Vue") {
		t.Error("chat.js contains external libraries")
	}
}
