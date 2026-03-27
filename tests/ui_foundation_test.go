package tests

import (
	"net/http"

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
