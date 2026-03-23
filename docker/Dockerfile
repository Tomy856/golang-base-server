FROM golang:1.26-alpine

RUN apk add --no-cache git

WORKDIR /server

COPY go.mod go.sum* ./
RUN go mod tidy

COPY . .

CMD ["go", "run", "cmd/main.go"]