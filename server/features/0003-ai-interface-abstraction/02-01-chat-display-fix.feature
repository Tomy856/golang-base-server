# ADR 0001, 0002 参照
# チケット 0003: AIインターフェース抽象化
# Step 2-01: チャット表示修正 - メッセージ送信時のUI切り替えとメッセージ描画

Feature: メッセージ送信時のチャット表示切り替え
  As ユーザー
  I want テキストを送信したとき「何から始めますか？」が消えてチャットが表示される
  So that 送受信の流れが視覚的にわかるUIで対話できる

  Background:
    Given サーバーが起動している
    And ブラウザで / にアクセスしている
    And 初期表示として #initialView（「何から始めますか？」）が表示されている
    And #messageContainer は非表示（display:none）になっている

  Scenario: 送信時に initialView が非表示になること
    Given ユーザーが "こんにちは" を #message 入力フィールドに入力した
    When 送信ボタン #send をクリックする
    Then #initialView が非表示（display:none）になること
    And #messageContainer が表示状態（display:block または display:flex）になること

  Scenario: 送信したメッセージがチャットエリアに表示されること
    Given ユーザーが "テストメッセージ" を #message 入力フィールドに入力した
    When 送信ボタン #send をクリックする
    Then #messageContainer 内にユーザーメッセージのバブルが追加されること
    And そのバブルのテキストが "テストメッセージ" であること
    And ユーザーメッセージは右寄せで表示されること

  Scenario: AIの回答がユーザーメッセージの直後に表示されること
    Given ユーザーが "質問です" を送信した
    And サーバーが { "reply": "これは回答です", "status": "success" } を返却した
    When レスポンスを受け取る
    Then #messageContainer 内にAI回答バブルが追加されること
    And そのバブルのテキストが "これは回答です" であること
    And AI回答は左寄せで表示されること
    And ユーザーメッセージとAI回答が対になってチャットエリアに並んでいること

  Scenario: メッセージバブルがTailwindクラス非依存でスタイリングされていること
    Given chat.js の renderMessage 関数が呼ばれた
    When role が "user" のバブルを描画する
    Then バブル要素にインラインスタイルまたはCSS変数ベースのスタイルが適用されること
    And Tailwind CDN 未読み込み環境でもレイアウトが崩れないこと
    And バブルのテキストが視認可能な色とパディングで表示されること

  Scenario: 送信後に入力フィールドがクリアされること
    Given ユーザーが "送信テスト" を入力した
    When 送信ボタン #send をクリックする
    Then #message の value が空文字になること
    And 文字数カウント #charCount が "0 / 2000" に戻ること
