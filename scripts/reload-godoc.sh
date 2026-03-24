#!/usr/bin/env bash

# 1. 既存 godoc プロセスを停止
pkill -f 'godoc' 2>/dev/null || true

# 2. プロジェクトルートへ移動
cd "$(dirname "$0")/.."

# 3. godoc を完全に切り離して起動
setsid nohup godoc -http=0.0.0.0:6060 -index -index_interval=0 > /tmp/godoc.log 2>&1 < /dev/null &

echo "godoc restarted on :6060 (log: /tmp/godoc.log)"
echo "PID: $!"
