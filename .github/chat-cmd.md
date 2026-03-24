# Chatコマンド依頼テンプレート

このファイルは、GitHub Copilotやチームチャットで統一して使う依頼表現をまとめたものです。

## godoc
- 依頼文言: `godocの更新をお願い`
- 実行: `/server/scripts/reload-godoc.sh`
- 確認: `curl -I http://127.0.0.1:6060/pkg/`

## air
- 依頼文言: `airでビルドして` / `air再起動して`
- 実行: `cd /server && air`
- 補足: `air` はアプリ実行のみで docs は別処理

## デプロイ（例）
- 依頼文言: `deploy準備して` / `デプロイ対応をお願い`
- 実行: `シェルや CI を実行` (プロジェクト独自)

## 追加機能対応
`chat-cmd` フォルダに機能別 markdown を追加していって下さい。
