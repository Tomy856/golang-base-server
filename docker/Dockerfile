# golang:1.24-bookworm をベースにする
FROM golang:1.24-bookworm

# Node.js 20.x を追加インストール
RUN apt-get update && apt-get install -y procps git graphviz curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /server

COPY go.mod go.sum* ./
RUN go mod download

# air / godoc / go-callvis を開発コンテナ内にインストール
RUN go install github.com/air-verse/air@v1.61.7 \
 && go install golang.org/x/tools/cmd/godoc@latest \
 && go install github.com/ofabry/go-callvis@latest

COPY . .

# Node.js 依存パッケージをインストール（docker/package.json を使用）
RUN cd docker && npm install

# package.json をルートにコピーして依存をインストール（static/js/server.js 用）
COPY docker/package.json ./package.json
RUN npm install

# 起動スクリプト:
#   1. godoc をバックグラウンド起動
#   2. Node.js AIプロキシをバックグラウンド起動
#   3. air をフォアグラウンド起動（ホットリロード）
CMD ["sh", "-c", \
    "godoc -http=0.0.0.0:6060 -index -index_interval=0 & \
     node static/js/server.js & \
     exec air"]
