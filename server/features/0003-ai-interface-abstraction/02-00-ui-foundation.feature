# ADR 0001, 0002 参照
# チケット 0003: AIインターフェース抽象化
# Step 2: フロントエンド基盤 - HTML/CSS/Vanilla JS フレームワーク
# デザイン基準: 2026-03-26 アップロード画像に基づくモダンUI

Feature: チャット UI の基盤構築
  As フロントエンドエンジニア
  I want 画像に基づいたモダンな HTML テンプレートと Vanilla JS で UI を構築する
  So that ユーザーが洗練されたインターフェースで AI と対話できる

  Background:
    Given サーバーが起動している
    And ブラウザで / にアクセスしている

  Scenario: index.html のレンダリングと要素の存在確認
    When GET / にアクセスする
    Then ステータスコード 200 が返却される
    And HTML ドキュメントが読み込まれる
    And 以下の UI 要素が画像のデザイン通りに存在する:
      | 要素名           | セレクタ          | 役割                                   |
      | チャットエリア   | #chat             | メッセージログの表示                   |
      | 入力フィールド   | #message          | ユーザーのテキスト入力                 |
      | 送信ボタン       | #send             | メッセージの送信実行                   |
      | 知識ベースリスト | #activeAgentsList | Work_KB / Hobby_KB の切り替え表示用    |

  Scenario: Vanilla JS (chat.js) の読み込みと関数定義の確認
    When GET / にアクセスする
    Then /static/js/chat.js が読み込まれている
    And chat.js 内に以下のロジックを構成する関数が存在する:
      | 関数名          | 説明                          |
      | sendMessage()   | APIへの送信とUI更新の統合処理 |
      | generateUUID()  | セッション管理用のID生成      |

  Scenario: 外部ライブラリ不使用の検証
    When GET /static/js/chat.js を確認する
    Then jQuery, React, Vue などの重量級 JS フレームワークが使用されていないこと
    And Tailwind CSS と Vanilla JS の組み合わせで軽量に動作すること

  Scenario: レスポンシブと基本レイアウトの確認
    Then サイドバーの幅が 280px であること
    And 背景色がダークテーマ（#0B0E14 基準）に設定されていること