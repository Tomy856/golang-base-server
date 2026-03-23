# [ADR-番号] タイトル

## Status
- [ ] Proposed / [ ] Accepted / [ ] Superseded (by [ADR-XX])

## Context (背景)
- 解決したい課題、技術的な制約、ビジネス要件を記述。
- 例: 「現在のRedis構成では、特定のスパイク時にメモリ不足が発生している」

## Decision (決定)
- 採用する解決策を明記。
- 例: 「書き込み負荷分散のため、PostgreSQLのパーティショニングを採用する」

## Alternatives Considered (検討した代替案と却下理由)
- **案A (Redis Cluster)**: 運用コストが高すぎるため却下。
- **案B (Memcached)**: 永続化要件を満たさないため却下。

## Consequences (結果・影響)
- 導入後に発生する制限や、今後の開発で守るべきルール。
- AIへの指示: 「今後、このモジュールの実装ではXXライブラリを直接呼ばないこと」