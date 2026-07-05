---
name: bedrock-rate-limit-check
description: |
  Wantedly の Amazon Bedrock rate limit 調査・見積もりを支援するスキル。
  新しいプロダクト機能やサービスが Bedrock (特に Anthropic Claude モデル) を使いたい場合に、
  既存の使用量と新規見積もりを比較して Quota 引き上げが必要かを判断する。

  以下のキーワードで発動:
  - 「Bedrock の rate limit / quota を確認したい」
  - 「Haiku / Sonnet / Claude で rate limit に達しそうか確認して」
  - 「Bedrock の使用量を見積もりたい」
  - 「Quota 引き上げが必要か確認して」
  - 「新機能で Bedrock を使いたい、rate limit は大丈夫か」
---

# Bedrock Rate Limit Check

Wantedly の AWS Bedrock 環境における rate limit 調査ワークフロー。

アーキテクチャ・プロファイル一覧・クォータ値・過去実績は `references/architecture.md` を参照。

## ワークフロー

### 1. 対象リージョンと既存 profile ID を特定

Hire (ats-rails) は `ap-northeast-1`、他のプロダクトは `us-west-2` がメイン。

```bash
# Application inference profile 一覧（Haiku 4.5 で絞り込む例）
aws bedrock list-inference-profiles --region ap-northeast-1 --type-equals APPLICATION \
  | jq '.inferenceProfileSummaries[] | select(.inferenceProfileName | contains("haiku-4-5")) | {id: .inferenceProfileId, name: .inferenceProfileName}'
```

既知の profile ID は `references/architecture.md` に記載済み。

### 2. 既存使用量を CloudWatch で取得

```bash
PROFILE_ID=urvozc88lce5
REGION=ap-northeast-1

# 過去30日の合計
for metric in Invocations InputTokenCount OutputTokenCount; do
  val=$(aws cloudwatch get-metric-statistics \
    --region $REGION --namespace AWS/Bedrock --metric-name $metric \
    --dimensions Name=ModelId,Value=$PROFILE_ID \
    --start-time $(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --period 2592000 --statistics Sum \
    | jq '.Datapoints[0].Sum // 0')
  echo "$metric: $val"
done

# ピーク TPM / RPM（1分単位）
aws cloudwatch get-metric-data \
  --region $REGION \
  --start-time $(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --metric-data-queries "[
    {\"Id\":\"tpm\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/Bedrock\",\"MetricName\":\"InputTokenCount\",\"Dimensions\":[{\"Name\":\"ModelId\",\"Value\":\"$PROFILE_ID\"}]},\"Period\":60,\"Stat\":\"Sum\"}},
    {\"Id\":\"rpm\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/Bedrock\",\"MetricName\":\"Invocations\",\"Dimensions\":[{\"Name\":\"ModelId\",\"Value\":\"$PROFILE_ID\"}]},\"Period\":60,\"Stat\":\"Sum\"}}
  ]" \
  | jq '.MetricDataResults[] | {id: .Id, peak: ([.Values[] | numbers] | if length > 0 then max else 0 end), avg: ([.Values[] | numbers] | if length > 0 then (add/length) else 0 end)}'
```

### 3. 現在のクォータを確認

```bash
aws service-quotas list-service-quotas --service-code bedrock --region ap-northeast-1 \
  | jq '.Quotas[] | select(.QuotaName | contains("Haiku 4.5")) | {name: .QuotaName, value: .Value}'
```

### 4. 見積もりと比較

リージョン内の全 prod profile の合算ピーク + 新規見積もりをクォータと比較する。

```
使用率 = (既存合算ピーク + 新規見積もりピーク) / クォータ
```

- **10% 未満**: 引き上げ不要
- **10〜50%**: 余裕はあるが将来的な増加に注意
- **50% 超**: 引き上げ申請を検討

### 5. 結果を Issue にコメント

- 既存使用量の表（リージョン別）
- 追加後の合算・クォータ・使用率の表
- 結論（Quota 引き上げ不要 or 申請が必要）

## 注意事項

- `EstimatedTPMQuotaUsage` は profile 単位クォータを「1」として計算するため数万 % が出ることがある。実際の TPM 値で判断すること
- クォータはリージョン単位。us-west-2 と ap-northeast-1 のクォータは独立
- cross-region profile の場合、クォータ消費は profile が属するリージョンのクォータにカウントされる
