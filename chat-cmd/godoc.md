# godoc更新コマンド

## 概要
`godoc` の再起動をチャット依頼で呼び出すための標準ドキュメントです。

## 依頼フレーズ
- `godocの更新をお願い`
- `godoc再生成して`
- `docsキャッシュクリアして`

## 実行コマンド
```bash
cd /server
./scripts/reload-godoc.sh
```

## 確認
- `http://127.0.0.1:6060/pkg/` にアクセス
- `curl -I http://127.0.0.1:6060/pkg/` に `200` か `301` が返る
