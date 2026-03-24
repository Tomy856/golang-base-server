#!/usr/bin/env bash
set -euo pipefail

# ポートフォワードが確立するまで待機
sleep 3

# 1. 既存 godoc プロセスを停止（厳密指定）
pkill -f '^godoc -http=0\.0\.0\.0:6060$' 2>/dev/null || true

# 2. プロジェクトルートへ移動
cd "$(dirname "$0")/.."

# 3. godoc を起動（バックグラウンド、チャット運用向け）
nohup godoc -http=0.0.0.0:6060 -index -index_interval=0 > /tmp/godoc.log 2>&1 &

echo "godoc restarted on :6060 (log: /tmp/godoc.log)"

echo "PID: $!"
