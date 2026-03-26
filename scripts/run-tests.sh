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

# 3. 出力先ディレクトリの設定と前回結果のクリーンアップ
OUT_DIR="$PROJECT_ROOT/tests"
COVERAGE_OUT="$OUT_DIR/coverage.out"
TEST_RESULT_LOG="$OUT_DIR/test_result.log"
rm -f "$COVERAGE_OUT" "$TEST_RESULT_LOG"

# 4. カバレッジ計測対象パッケージを列挙
#    tests/ は外部テストパッケージのため -coverpkg で internal を明示指定する
#    go list ./... から tests パッケージ自身を除いた全パッケージを対象にする
COVERPKG=$(go list ./... | grep -v "^golang-base-server/tests$" | tr '\n' ',')
COVERPKG="${COVERPKG%,}"  # 末尾カンマを除去

echo "📦 カバレッジ計測対象: $COVERPKG"

# 5. テスト実行
echo "🧪 テストを実行しています..."
if ! go test -v -coverprofile="$COVERAGE_OUT" -coverpkg="$COVERPKG" ./... > "$TEST_RESULT_LOG" 2>&1; then
    echo ""
    echo "❌ テスト失敗"
    echo "--- 失敗したテスト ---"
    grep -E "^(--- FAIL|FAIL)" "$TEST_RESULT_LOG" || true
    echo ""
    echo "--- 詳細ログ ($TEST_RESULT_LOG) ---"
    cat "$TEST_RESULT_LOG"
    exit 1
fi

# 6. カバレッジの抽出
if [ ! -f "$COVERAGE_OUT" ]; then
    echo "❌ coverage.out が生成されませんでした。テストが実行されていない可能性があります。"
    exit 1
fi

total_coverage=$(go tool cover -func="$COVERAGE_OUT" | grep "^total:" | awk '{print $3}')

# 7. カバレッジが 0.0% の場合は空振り判定
if [ "$total_coverage" = "0.0%" ]; then
    echo "❌ Total Coverage が 0.0% です。テストが正しく実行されていません（空振り）。"
    exit 1
fi

# 8. 成功出力
echo ""
echo "✅ テスト成功"
echo "=================================="
echo " Status   : PASS"
echo " Coverage : $total_coverage"
echo " Path     : $(pwd)"
echo " 出力先   : $OUT_DIR"
echo "=================================="
