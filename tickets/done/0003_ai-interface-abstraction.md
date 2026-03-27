# Ticket: 0003 AIインターフェースの抽象化
- **Jira**: N/A
- **Status**: In Progress

## 1. Context & Goals
AIインターフェースの抽象化: クライアントがGeminiやBedrockの仕様を意識せず、統一されたインターフェースでAIと対話できる基盤を作るため。

疎結合な開発環境の構築: フロントエンド（表示）とバックエンド（AIロジック）を分離し、将来的にUIをCLIやスマホアプリ等へ容易に差し替え可能にするため。

「生きたモック」の刷新: 現在の Hello World 状態を脱し、実際にAPI経由でデータが流れる最小限の「垂直スライス」を完成させるため。

## 2. BDD Scenarios

**詳細な BDD scenarios は以下の `.feature` ファイルに分割・実装可能な単位で定義されています：**

| ファイル | 説明 |
|---------|------|
| `/server/features/0003-ai-interface-abstraction/01-api-foundation.feature` | Step 1: バックエンド基盤 - API エンドポイント・データ構造の確立 |
| `/server/features/0003-ai-interface-abstraction/02-00-ui-foundation.feature` | Step 2: フロントエンド基盤 - HTML/CSS/Vanilla JS フレームワーク |
| `/server/features/0003-ai-interface-abstraction/02-01-chat-display-fix.feature` | Step 2-01: チャット表示修正 - 送信時のinitialView切り替えとメッセージ描画（Tailwind非依存） |
| `/server/features/0003-ai-interface-abstraction/03-happy-path.feature` | Step 3: 正常系フロー - ユーザー入力 → サーバー処理 → UI 表示 |
| `/server/features/0003-ai-interface-abstraction/04-client-validation.feature` | Step 4: フロントエンドバリデーション - Scenario 1 |
| `/server/features/0003-ai-interface-abstraction/05-server-error-handling.feature` | Step 5: サーバー側エラー処理 - Scenario 2 |
| `/server/features/0003-ai-interface-abstraction/06-frontend-timeout.feature` | Step 6: フロントエンドタイムアウト処理 - Scenario 3 |

### Scenario 0: 正常系 - AI への質問と応答 (200)
- **Given**: ユーザーが有効なメッセージを入力し、送信ボタンを押下した
- **When**: サーバーが Gemini API 経由で正常なレスポンス `{ "reply": "...", "status": "success" }` を返却した
- **Then**:
  - チャットエリアにユーザーの入力とAIの回答が対になって追加される
  - 入力フィールドがクリアされ、フォーカスが戻る
  - 送信ボタンが再度有効化される
- **参照**: `/server/features/0003-ai-interface-abstraction/03-happy-path.feature`

### Scenario 1: クライアント側エラー (4xx)
- **Given**: ユーザーが空文字、または制限文字数を超える入力を送信した
- **When**: 送信ボタンが押下される
- **Then**: APIを叩く前にフロントエンドでバリデーションエラーを表示し、API通信（POST）を発生させないこと。
- **参照**: `/server/features/0003-ai-interface-abstraction/04-client-validation.feature`

### Scenario 2: サーバー側・AI APIエラー (5xx)
- **Given**: Gemini/Bedrockのクォータ制限や一時的なダウンが発生した
- **When**: サーバーが 500 または 503 エラーを返却する
- **Then**: チャットエリアに「一時的にAIが応答できません。時間を置いて再度お試しください」とエラーメッセージを表示する。入力フィールドの内容を保持したまま、送信ボタンを再度有効化（リトライ可能状態）にする。
- **参照**: `/server/features/0003-ai-interface-abstraction/05-server-error-handling.feature`

### Scenario 3: タイムアウト挙動
- **Given**: AIからの応答が30秒以上経過しても返ってこない
- **When**: フロントエンドのタイムアウトが発生する
- **Then**: 接続を遮断し、「応答がタイムアウトしました」と表示。ユーザーに再送を促す。
- **参照**: `/server/features/0003-ai-interface-abstraction/06-frontend-timeout.feature`

## 2.5 JSON Schema Definition

### Request Format (POST /api/chat)
```json
{
  "message": "string (1-2000文字、必須)",
  "session_id": "string (UUID形式、必須)"
}
```

### Response Format (200 OK)
```json
{
  "reply": "string (AI からの応答、必須)",
  "status": "string (enum: 'success' | 'error', 必須)",
  "error_message": "string (status='error' の場合のみ、エラー説明)"
}
```

### Error Response Format (4xx / 5xx)
```json
{
  "reply": null,
  "status": "error",
  "error_message": "string (詳細エラーメッセージ)"
}
```

## 3. Implementation Constraints (ADR/Symbols)
- **参照ADR**: [[0001-tech-stack-constraints.md]], [[0002-sdd-bdd-workflow.md]]
- **再利用資産**: `internal/application/hello.go` の構造を参考にUsecase層を拡張、`internal/infrastructure/logger.go` のLogErrorを再利用
- **懸念点と解決策**: セキュリティ: AI APIキー管理（環境変数使用）。パフォーマンス: タイムアウト設定（30秒）。拡張性: リポジトリパターン採用。

## 3.5 UI Configuration

### ファイル構成
- **テンプレート**: `/templates/index.html`
  - Go (Gin) の `c.HTML()` でレンダリング
  - チャットエリア、入力フィールド、送信ボタンの基本構造
  - **参照 BDD**: `/server/features/0003-ai-interface-abstraction/02-00-ui-foundation.feature`

- **JavaScript**: `/static/js/chat.js`
  - Vanilla JS のみ使用（外部ライブラリ・Tailwind CDN 不使用）
  - メッセージバブルはインラインスタイルで描画（Tailwind クラス非依存）
  - メッセージ送信、initialView切り替え、UI更新、バリデーション、エラーメッセージ表示を実装
  - タイムアウト処理（30秒、AbortController使用）を含む
  - **参照 BDD**:
    - `/server/features/0003-ai-interface-abstraction/02-00-ui-foundation.feature`
    - `/server/features/0003-ai-interface-abstraction/02-01-chat-display-fix.feature`
    - `/server/features/0003-ai-interface-abstraction/04-client-validation.feature`
    - `/server/features/0003-ai-interface-abstraction/06-frontend-timeout.feature`

### UI フロー
1. ユーザーが入力フィールドにメッセージを入力
2. 送信ボタン押下時に Vanilla JS でバリデーション実行
3. 有効な場合、#initialView を非表示 → #messageContainer を表示
4. POST `/api/chat` へ JSON リクエスト送信（AbortController で30秒タイムアウト）
5. レスポンス受け取り後、チャットエリアに対話を追加（インラインスタイルのバブル）
6. エラー・タイムアウト発生時は相応のメッセージをチャットエリアに表示
**参照 BDD**: `/server/features/0003-ai-interface-abstraction/03-happy-path.feature, 05-server-error-handling.feature`

## 4. Definition of Done
- [x] API基盤 (POST /api/chat) の実装完了
- [x] リクエスト/レスポンス構造定義完了
- [x] バリデーション(1-2000文字、UUID)と固定成功レスポンス実装完了
- [x] 単体テスト追加完了
- [x] テストカバレッジ 80% 以上 (仮定)
- [x] `bdd-done` フローの実行完了
- [x] 02-01-chat-display-fix.feature: 送信時 initialView 非表示・メッセージバブル描画修正完了
- [ ] 03-happy-path.feature: 正常系フロー - ユーザー入力 → サーバー処理 → UI 表示
- [ ] 04-client-validation.feature: フロントエンドバリデーション
- [ ] 05-server-error-handling.feature: サーバー側エラー処理
- [ ] 06-frontend-timeout.feature: フロントエンドタイムアウト処理
