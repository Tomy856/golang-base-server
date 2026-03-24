#!/bin/bash
# .envファイルにUID/GIDを書き込む（docker-compose起動前に実行）
echo "DOCKER_UID=$(id -u)" > .env
echo "DOCKER_GID=$(id -g)" >> .env
echo ".env updated: DOCKER_UID=$(id -u), DOCKER_GID=$(id -g)"
