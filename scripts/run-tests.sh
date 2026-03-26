#!/bin/bash
set -euo pipefail

# ============================================================
# run-tests.sh
# 使い方: プロジェクトルートまたはどこからでも直接実行可能
#   bash scripts/run-tests.sh
#   ./scripts/run-tests.sh  (chmod +x 済みの場合)
# ============================================================

# 1. スクリプトの場所を起点にプロジェクトルートへ移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT" || { echo "❌ プロジェクトルートへの移動に失敗しました: $PROJECT_ROOT"; exit 1; }

echo "📁 実行ディレクトリ: $(pwd)"

# 2. ログディレクトリの自動作成
mkdir -p logs/error

# 3. 一時ファイルのクリーンアップ（前回の結果を残さない）
rm -f coverage.out test_result.log

# 4. テスト実行
echo "🧪 テストを実行しています..."
if ! go test -v -coverprofile=coverage.out ./... > test_result.log 2>&1; then
    echo ""
    echo "❌ テスト失敗"
    echo "--- 失敗したテスト ---"
    grep -E "^(--- FAIL|FAIL)" test_result.log || true
    echo ""
    echo "--- 詳細ログ (test_result.log) ---"
    cat test_result.log
    exit 1
fi

# 5. カバレッジの抽出
if [ ! -f coverage.out ]; then
    echo "❌ coverage.out が生成されませんでした。テストが実行されていない可能性があります。"
    exit 1
fi

total_coverage=$(go tool cover -func=coverage.out | grep "^total:" | awk '{print $3}')

# 6. カバレッジが 0.0% の場合は空振り判定
if [ "$total_coverage" = "0.0%" ]; then
    echo "❌ Total Coverage が 0.0% です。テストが正しく実行されていません（空振り）。"
    exit 1
fi

# 7. 成功出力
echo ""
echo "✅ テスト成功"
echo "=================================="
echo " Status   : PASS"
echo " Coverage : $total_coverage"
echo " Path     : $(pwd)"
echo "=================================="
