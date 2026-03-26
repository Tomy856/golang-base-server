#!/bin/bash
# 1. 全テスト実行とカバレッジ出力
go test -coverprofile=coverage.out ./... > test_result.log

# 2. カバレッジの総計を抽出
total_coverage=$(go tool cover -func=coverage.out | grep "total:" | awk '{print $3}')

# 3. 失敗したテストがあるか確認
if grep -q "FAIL" test_result.log; then
    echo "❌ Test Failed!"
    cat test_result.log | grep "FAIL"
    exit 1
fi

# 4. 結果を標準出力（AIが読み取れる形）で表示
echo "--- TEST EVIDENCE ---"
echo "Status: PASS"
echo "Total Coverage: $total_coverage"
echo "---------------------"