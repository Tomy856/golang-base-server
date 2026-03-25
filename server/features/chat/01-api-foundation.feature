# ADR 0001, 0002 参照
# チケット 0003: AIインターフェース抽象化
# Step 1: バックエンド基盤 - API エンドポイント・データ構造の確立

Feature: チャット API の基盤構築 
  As バックエンドエンジニア
  I want チャット API エンドポイント `/api/chat` を実装する
  So that フロントエンドから JSON リクエストを受け取り、JSON レスポンスを返却できる

  Background:
    Given サーバーが起動している
    And 環境変数 `AI_PROVIDER` が設定されている
    And セッション ID が有効な UUID 形式である

  Scenario: POST /api/chat エンドポイントの実装
    Given リクエストボディが以下の構造を持つ:
      """
      {
        "message": "こんにちは",
        "session_id": "550e8400-e29b-41d4-a716-446655440000"
      }
      """
    When POST /api/chat にリクエストを送信する
    Then ステータスコード 200 が返却される
    And レスポンスボディが以下の構造を持つ:
      """
      {
        "reply": "string",
        "status": "success",
        "error_message": null
      }
      """

  Scenario: メッセージフィールドのバリデーション (1-2000文字)
    Given リクエストボディ内の message が 1 文字以上 2000 文字以下の範囲內である
    When POST /api/chat にリクエストを送信する
    Then ステータスコード 200 が返却される

  Scenario: session_id フィールドの UUID 検証
    Given リクエストボディ内の session_id が有効な UUID 形式である
    When POST /api/chat にリクエストを送信する
    Then ステータスコード 200 が返却される
