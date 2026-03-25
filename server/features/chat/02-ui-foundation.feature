# ADR 0001, 0002 参照
# チケット 0003: AIインターフェース抽象化
# Step 2: フロントエンド基盤 - HTML/CSS/Vanilla JS フレームワーク

Feature: チャット UI の基盤構築
  As フロントエンドエンジニア
  I want HTML テンプレートと Vanilla JS で UI を構築する
  So that ユーザーがブラウザでチャットインターフェースを操作できる

  Background:
    Given サーバーが起動している
    And ブラウザで / にアクセスしている

  Scenario: index.html のレンダリング
    When GET / にアクセスする
    Then ステータスコード 200 が返却される
    And HTML ドキュメントが読み込まれる
    And 以下の UI 要素が存在する:
      | 要素名           | セレクタ          |
      | チャットエリア   | #chatMessages     |
      | 入力フィールド   | #messageInput     |
      | 送信ボタン       | #sendButton       |

  Scenario: Vanilla JS (chat.js) の読み込み
    When GET / にアクセスする
    Then /static/js/chat.js が読み込まれている
    And chat.js 内に以下の関数が存在する:
      | 関数名          | 説明                          |
      | sendMessage()   | メッセージ送信処理            |
      | displayMessage()| チャット画面への表示処理      |
      | validateInput() | 入力バリデーション処理        |

  Scenario: 外部ライブラリ不使用の検証
    When GET /static/js/chat.js を確認する
    Then jQuery, React, Vue などの外部 JS フレームワークが使用されていないこと
    And Vanilla JS のみで実装されていること
