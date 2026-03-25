# callvis 可視化更新

## 概要
`go-callvis` を使って関数の呼び出し関係図（SVG）を生成し、  
`internal` 配下の公開シンボルを一覧化した Markdown を更新します。

| 成果物 | パス |
|---|---|
| 呼び出し関係図 | `docs/diagrams/project_structure.svg` |
| シンボルマップ | `docs/current_symbols.md` |

## 依頼フレーズ
- `callvis更新して`
- `解析図を再生成して`
- `関数マップ更新`

## 実行コマンド
```bash
cd /server && ./scripts/reload-callvis.sh
```

## 前提条件
コンテナ内に以下がインストール済みであること。

```bash
# Graphviz
sudo apt-get update && sudo apt-get install -y graphviz

# go-callvis
go install github.com/ofabry/go-callvis@latest
```

## 補足
- `go-callvis` バイナリは `~/go/bin/` に配置されます。パスが通っていない場合はスクリプトが自動検出します。
- `-nostd` オプションにより標準ライブラリは図から除外されます。
- シンボルマップはテストファイル（`*_test.go`）を除外した `internal` 配下の公開関数・メソッドのみを抽出します。
