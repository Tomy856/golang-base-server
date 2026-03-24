#!/usr/bin/env bash
set -euo pipefail

# 1. 既存 godoc プロセスを停止（存在しない場合も成功扱い）
pkill godoc 2>/dev/null || true

# 2. プロジェクトルートへ移動
cd "$(dirname "$0")/.."

# 3. godoc をバックグラウンドで起動
nohup godoc -http=:6060 -index -index_interval=0 > /tmp/godoc.log 2>&1 &

echo "godoc restarted on :6060 (log: /tmp/godoc.log)"
