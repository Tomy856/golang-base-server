# ADR 0001, 0002 参照
# チケット 0003: AIインターフェース抽象化
# Step 5: サーバー側エラー処理 - Scenario 2

Feature: サーバー側・AI API エラーの処理
  As ユーザー
  I want AI API が一時的に利用不可の場合にエラーメッセージを見る
  So that AI が応答できない状況を理解できる

  Background:
    Given ブラウザで / にアクセスしている
    And 入力フィールドに "テストメッセージ" が入力されている
    And 送信ボタン #sendButton が有効である

  Scenario: Scenario 2 - AI API エラー (500/503) の処理
    Given Gemini/Bedrock API がクォータ制限またはダウン状態にある
    When ユーザーが送信ボタン #sendButton をクリックする
    Then サーバーが 500 または 503 ステータスコードを返却する
    And フロントエンドが以下のメッセージを表示する:
      | メッセージ |
      | 一時的にAIが応答できません。時間を置いて再度お試しください |
    And チャットエリアにエラーメッセージが表示される
    And 入力フィールドの内容が保持されたままである
    And 送信ボタン #sendButton が再度有効化される

  Scenario: リトライ可能状態への復帰
    Given エラーメッセージが表示されている
    And ユーザーが再度送信ボタン #sendButton をクリックする
    When 送信ボタンをクリックする
    Then 新たなリクエストが POST /api/chat に送信される
    And 入力フィールドの内容は保持されたままである

  Scenario: AI API タイムアウトエラーの処理 (Gateway Timeout)
    Given AI API がレスポンス時間制限（30秒）を超過している
    When サーバーが 504 Gateway Timeout エラーを返却する
    Then フロントエンドが適切なエラーメッセージを表示する
