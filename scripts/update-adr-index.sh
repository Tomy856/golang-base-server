#!/bin/bash

# scripts/update-adr-index.sh

# スクリプトの場所を基準にルートディレクトリを計算（どの cwd から実行しても動作）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ADR_DIR="$ROOT_DIR/docs/adr"
INDEX_FILE="$ADR_DIR/README.md"

# 1. 目次のヘッダー作成
echo "# ADR Index (Architecture Decision Records)" > "$INDEX_FILE"
echo "最終更新: $(date '+%Y-%m-%d %H:%M:%S')" >> "$INDEX_FILE"
echo "" >> "$INDEX_FILE"
echo "| ID | 日付 | タイトル | ステータス | 最終更新日 |" >> "$INDEX_FILE"
echo "|:---|:---|:---|:---|:---|" >> "$INDEX_FILE"

# 2. 各ADRファイルから情報を抽出してテーブルに追加
# ファイル名が 001_xxx.md の形式であることを想定
for file in $(ls $ADR_DIR/[000-999]*.md | sort); do
    filename=$(basename "$file")
    id=$(echo "$filename" | cut -d'_' -f1)
    
    # ファイル内の特定の行から情報を抽出
    title=$(grep -m 1 "^# ADR:" "$file" | sed 's/# ADR: //')
    date=$(grep -m 1 "^- \*\*日付\*\*:" "$file" | sed 's/- \*\*日付\*\*: //')
    status=$(grep -m 1 "^- \*\*ステータス\*\*:" "$file" | sed 's/- \*\*ステータス\*\*: //')
    last_mod=$(date -r "$file" '+%Y-%m-%d')

    echo "| $id | $date | [$title]($filename) | $status | $last_mod |" >> "$INDEX_FILE"
done

echo "ADR Index updated at $INDEX_FILE"