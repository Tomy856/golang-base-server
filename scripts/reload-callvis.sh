#!/bin/bash
# 1. 既存の symbols フォルダをリセット
mkdir -p docs/symbols
rm -f docs/symbols/*.md

# 2. 全体のインデックス (symbols_map.md) を作成
echo "# Project Symbols Map" > docs/symbols_map.md
echo "生成日: $(date)" >> docs/symbols_map.md
echo "" >> docs/symbols_map.md

# 3. パッケージごとにシンボルを抽出
# internal 配下の各ディレクトリをループ
for dir in $(find internal -type d); do
    pkg_name=$(basename "$dir")
    # 中身が空でないか確認
    if ls "$dir"/*.go >/dev/null 2>&1; then
        target_file="docs/symbols/${pkg_name}.md"
        echo "## Package: $pkg_name" > "$target_file"
        
        # 構造体とインターフェース、主要な関数を抽出して各ファイルへ
        grep -E "type [A-Z].* (struct|interface)" "$dir"/*.go >> "$target_file" 2>/dev/null
        grep -E "func [A-Z].*" "$dir"/*.go >> "$target_file" 2>/dev/null
        
        # インデックスファイルにリンクを追記
        echo "- [[$pkg_name]]: $dir" >> docs/symbols_map.md
    fi
done

# 4. 既存の go-callvis (SVG生成) も実行
# (ここに既存の callvis コマンドを記述)

#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# reload-callvis.sh
# 呼び出し関係図（SVG）とシンボルマップ（Markdown）を生成・更新するスクリプト
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIAGRAMS_DIR="${PROJECT_ROOT}/docs/diagrams"
SYMBOLS_FILE="${PROJECT_ROOT}/docs/current_symbols.md"
MODULE_NAME="golang-base-server"

cd "${PROJECT_ROOT}"

# ------------------------------------------------------------------------------
# 1. 出力ディレクトリの準備
# ------------------------------------------------------------------------------
mkdir -p "${DIAGRAMS_DIR}"

# ------------------------------------------------------------------------------
# 2. go-callvis のパスを解決
# ------------------------------------------------------------------------------
CALLVIS_BIN=""
if command -v go-callvis &>/dev/null; then
  CALLVIS_BIN="go-callvis"
elif [ -x "${HOME}/go/bin/go-callvis" ]; then
  CALLVIS_BIN="${HOME}/go/bin/go-callvis"
elif [ -x "/root/go/bin/go-callvis" ]; then
  CALLVIS_BIN="/root/go/bin/go-callvis"
else
  echo "ERROR: go-callvis が見つかりません。" >&2
  echo "  インストール: go install github.com/ofabry/go-callvis@latest" >&2
  exit 1
fi
echo "go-callvis: ${CALLVIS_BIN}"

# ------------------------------------------------------------------------------
# 3. graphviz (dot) の確認
# ------------------------------------------------------------------------------
if ! command -v dot &>/dev/null; then
  echo "ERROR: graphviz (dot) が見つかりません。" >&2
  echo "  インストール: sudo apt-get install -y graphviz" >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# 4. 呼び出し関係図（SVG）の生成
# ------------------------------------------------------------------------------
SVG_OUT="${DIAGRAMS_DIR}/project_structure.svg"
echo "▶ 呼び出し関係図を生成中: ${SVG_OUT}"

"${CALLVIS_BIN}" \
  -format svg \
  -focus main \
  -group pkg \
  -nostd \
  -file "${DIAGRAMS_DIR}/project_structure" \
  "${MODULE_NAME}/cmd/..." 2>/dev/null || \
"${CALLVIS_BIN}" \
  -format svg \
  -focus "${MODULE_NAME}" \
  -group pkg \
  -nostd \
  -file "${DIAGRAMS_DIR}/project_structure" \
  ./... 2>/dev/null || {
    echo "WARN: go-callvis の実行に失敗しました。SVG生成をスキップします。" >&2
  }

# go-callvis が .svg 拡張子なしで出力する場合に対応
if [ -f "${DIAGRAMS_DIR}/project_structure" ] && [ ! -f "${SVG_OUT}" ]; then
  mv "${DIAGRAMS_DIR}/project_structure" "${SVG_OUT}"
fi

[ -f "${SVG_OUT}" ] && echo "✔ SVG生成完了: ${SVG_OUT}" || echo "△ SVGファイルは生成されませんでした"

# ------------------------------------------------------------------------------
# 5. シンボルマップ（Markdown）の生成
# ------------------------------------------------------------------------------
echo "▶ シンボルマップを生成中: ${SYMBOLS_FILE}"

UPDATED_AT="$(date '+%Y-%m-%d %H:%M:%S')"

{
  echo "# Project Symbols Map"
  echo ""
  echo "> 最終更新: ${UPDATED_AT}"
  echo ""

  # internal 配下の .go ファイルを走査（テストファイルを除く）
  while IFS= read -r gofile; do
    # docs/current_symbols.md からの相対パス表示用
    rel_path="${gofile#${PROJECT_ROOT}/}"

    # 公開関数（func で始まり、関数名が大文字）を抽出
    funcs="$(grep -E '^func[[:space:]]+[A-Z]' "${gofile}" \
              | sed 's/{[[:space:]]*$//' \
              | sed 's/^[[:space:]]*//' \
              || true)"

    # 公開メソッド（レシーバ付き、メソッド名が大文字）を抽出
    methods="$(grep -E '^func[[:space:]]*\([^)]+\)[[:space:]]+[A-Z]' "${gofile}" \
               | sed 's/{[[:space:]]*$//' \
               | sed 's/^[[:space:]]*//' \
               || true)"

    combined="$(printf '%s\n%s' "${funcs}" "${methods}" | grep -v '^$' | sort -u || true)"

    # 公開シンボルがないファイルはスキップ
    [ -z "${combined}" ] && continue

    echo "## ${rel_path}"
    echo ""
    echo '```go'
    echo "${combined}"
    echo '```'
    echo ""
  done < <(find "${PROJECT_ROOT}/internal" -name "*.go" ! -name "*_test.go" | sort)

} > "${SYMBOLS_FILE}"

echo "✔ シンボルマップ生成完了: ${SYMBOLS_FILE}"
echo ""
echo "=== 完了 ==="
