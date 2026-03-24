# air v1.64.5 が要求する Go 1.25 をベースにする
FROM golang:1.25-bookworm

RUN apt-get update && apt-get install -y procps git

WORKDIR /server

COPY go.mod go.sum* ./
RUN go mod download

# air と godoc を開発コンテナ内にインストール
RUN go install github.com/air-verse/air@v1.64.5
RUN go install golang.org/x/tools/cmd/godoc@latest

COPY . .

# 起動時に godoc をバックグラウンドで立ち上げ、air を前景プロセスにする
CMD ["sh", "-c", "godoc -http=0.0.0.0:6060 & exec air"]