# Project Symbols Map

> 最終更新: 2026-03-26 02:16:20

## internal/application/chat.go

```go
func (u *chatUsecase) Chat(ctx context.Context, message string, sessionID string) (string, error) 
func NewChatUsecase() ChatUsecase 
```

## internal/application/hello.go

```go
func (u *helloUsecase) GetHello() (string, error) 
func NewHelloUsecase() HelloUsecase 
```

## internal/infrastructure/logger.go

```go
func LogError(err error) 
```

## internal/presentation/handler.go

```go
func (h *ChatHandler) PostChat(c *gin.Context) 
func (h *HelloHandler) GetHello(c *gin.Context) 
func NewChatHandler(usecase application.ChatUsecase) *ChatHandler 
func NewHelloHandler(usecase application.HelloUsecase) *HelloHandler 
```

