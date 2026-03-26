// Package main は golang-base-server のエントリーポイントを提供します。
package main

import (
	"fmt"
	"net/http"

	"golang-base-server/internal/application"
	"golang-base-server/internal/infrastructure"
	"golang-base-server/internal/presentation"

	"github.com/gin-gonic/gin"
)

// main はサーバーを起動します。
func main() {
	chatUsecase := application.NewChatUsecase()
	chatHandler := presentation.NewChatHandler(chatUsecase)

	r := gin.New()

	// Add logger middleware
	r.Use(gin.Logger())

	// Add custom recovery middleware to log errors
	r.Use(gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		infrastructure.LogError(fmt.Errorf("panic: %v", recovered))
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
	}))

	r.LoadHTMLGlob("templates/*")

	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{
			"title": "Chat Interface", // 必要に応じてタイトルなどを渡す
		})
	})
	r.POST("/api/chat", chatHandler.PostChat)
	r.Static("/static", "./static")
	r.Run()
}
