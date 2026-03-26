#!/bin/bash

# 1. 実行場所の自動補正（最重要）
# スクリプト自身の場所を起点に、プロジェクトルート (/server) へ移動
cd "$(dirname "$0")/.." || { echo "❌ Failed to move to project root"; exit 1; }

# 2. ログディレクトリの自動作成（マニュアルの手順を自動化）
mkdir -p logs/error

# 3. テスト実行
# ./... は /server 直下の go.mod を基準に全パッケージを対象にする
go test -v -coverprofile=coverage.out ./... > test_result.log 2>&1

# 4. カバレッジの抽出
total_coverage=$(go tool cover -func=coverage.out | grep "total:" | awk '{print $3}')

# カバレッジが 0.0% かどうかを判定
if [ "$total_coverage" = "0.0%" ]; then
    echo "❌ ERROR: Total Coverage is 0.0%. Tests are not running correctly!"
    exit 1
fi

# 5. 判定と出力
if grep -q "FAIL" test_result.log || [ ! -f coverage.out ]; then
    echo "❌ Test Failed!"
    grep "FAIL" test_result.log
    exit 1
fi

echo "--- TEST EVIDENCE ---"
echo "Status: PASS"
echo "Total Coverage: $total_coverage"
echo "Execution Path: $(pwd)"
echo "---------------------"