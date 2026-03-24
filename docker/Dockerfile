# golang:1.24-bookworm をベースにする
FROM golang:1.24-bookworm

RUN apt-get update && apt-get install -y procps git && rm -rf /var/lib/apt/lists/*

WORKDIR /server

COPY go.mod go.sum* ./
RUN go mod download

# air と godoc を開発コンテナ内にインストール
RUN go install github.com/air-verse/air@v1.61.7 \
 && go install golang.org/x/tools/cmd/godoc@latest

COPY . .

# godoc をバックグラウンドで起動してから air を前景プロセスにする
CMD ["sh", "-c", "godoc -http=0.0.0.0:6060 -index -index_interval=0 & exec air"]
