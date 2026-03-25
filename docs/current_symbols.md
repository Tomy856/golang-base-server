# Project Symbols Map

> 最終更新: 2026-03-25 02:54:25

## internal/application/hello.go

```go
func (u *helloUsecase) GetHello() (string, error) 
func NewHelloUsecase() HelloUsecase 
```

## internal/application/chat.go

```go
func (u *chatUsecase) Chat(ctx context.Context, message string, sessionID string) (string, error)
func NewChatUsecase() ChatUsecase
```

## internal/infrastructure/logger.go

```go
func LogError(err error) 
```

## internal/presentation/handler.go

```go
func (h *HelloHandler) GetHello(c *gin.Context) 
func NewHelloHandler(usecase application.HelloUsecase) *HelloHandler 
func (h *ChatHandler) PostChat(c *gin.Context)
func NewChatHandler(usecase application.ChatUsecase) *ChatHandler
```

