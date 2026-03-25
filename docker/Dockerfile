# golang:1.24-bookworm をベースにする
FROM golang:1.24-bookworm

RUN apt-get update && apt-get install -y procps git graphviz && rm -rf /var/lib/apt/lists/*

WORKDIR /server

COPY go.mod go.sum* ./
RUN go mod download

# air / godoc / go-callvis を開発コンテナ内にインストール
RUN go install github.com/air-verse/air@v1.61.7 \
 && go install golang.org/x/tools/cmd/godoc@latest \
 && go install github.com/ofabry/go-callvis@latest

COPY . .

# godoc をバックグラウンドで起動してから air を前景プロセスにする
CMD ["sh", "-c", "godoc -http=0.0.0.0:6060 -index -index_interval=0 & exec air"]
