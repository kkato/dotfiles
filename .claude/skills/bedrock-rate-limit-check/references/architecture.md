# Wantedly Bedrock アーキテクチャ

## リージョン構成

| リージョン | 用途 |
|---|---|
| `us-west-2` | メインリージョン（大半のサービス） |
| `ap-northeast-1` | Hire (ats-rails) 専用 |

Terraform: `wantedly-terraform/terraform/base_modules/bedrock/main.tf`

## Inference Profile の種類

### System Defined Profile（AWSが提供）
- ID 形式: `us.anthropic.claude-haiku-4-5-20251001-v1:0`
- CloudWatch の ModelId にはこの ID は**現れない**

### Application Inference Profile（独自定義）
- ID 形式: ランダム英数字（例: `82ye67zauvzh`）
- CloudWatch の `ModelId` ディメンションにこの ID が使われる
- 命名規則: `{app}-{model}-{env}`（例: `ats-rails-claude-haiku-4-5-prod`）

## 現在の Haiku 4.5 Application Inference Profile 一覧

### ap-northeast-1

| ID | 名前 | 用途 |
|---|---|---|
| `urvozc88lce5` | ats-rails-claude-haiku-4-5-prod | Hire 書類選考AI prod |
| `3gmiesxoc5f3` | ats-rails-claude-haiku-4-5-qa | Hire 書類選考AI qa |
| `w34h7iwncn9e` | ats-rails-claude-haiku-4-5-sandbox | Hire 書類選考AI sandbox |
| `f86khekcrhmm` | wantedly-claude-haiku-4-5-prod | wantedly prod |
| `69ph1peblqli` | wantedly-claude-haiku-4-5-qa | wantedly qa |
| `a2ao1s0gbtv1` | wantedly-claude-haiku-4-5-sandbox | wantedly sandbox |
| `cn4xcmgd7obd` | users-rails-claude-haiku-4-5-prod | users-rails prod |
| `ml9wzntot84u` | users-rails-claude-haiku-4-5-qa | users-rails qa |
| `f1zgk3zfah7t` | users-rails-claude-haiku-4-5-sandbox | users-rails sandbox |
| `6x6b8aa03011` | timeline-personalized-ranking-claude-haiku-4-5-prod | タイムライン推薦 prod |
| `zw9p0ge9c3kh` | timeline-personalized-ranking-claude-haiku-4-5-qa | タイムライン推薦 qa |
| `cz263oj84xd9` | timeline-personalized-ranking-claude-haiku-4-5-sandbox | タイムライン推薦 sandbox |

### us-west-2

| ID | 名前 | 用途 |
|---|---|---|
| `82ye67zauvzh` | wantedly-claude-haiku-4-5-prod | wantedly prod |
| `pg0ekmu0uegp` | wantedly-claude-haiku-4-5-qa | wantedly qa |
| `k1tku4t237t6` | wantedly-claude-haiku-4-5-sandbox | wantedly sandbox |
| `70wricn918yo` | users-rails-claude-haiku-4-5-prod | users-rails prod |
| `6cxksnfxxwvb` | users-rails-claude-haiku-4-5-qa | users-rails qa |
| `ncg1ndr17mn2` | users-rails-claude-haiku-4-5-sandbox | users-rails sandbox |
| `v7mn0icf72gs` | timeline-personalized-ranking-claude-haiku-4-5-prod | タイムライン推薦 prod |
| `lpq6928q6xpu` | timeline-personalized-ranking-claude-haiku-4-5-qa | タイムライン推薦 qa |
| `996sj0mslize` | timeline-personalized-ranking-claude-haiku-4-5-sandbox | タイムライン推薦 sandbox |
| `i4snu3l68u52` | ats-rails-claude-haiku-4-5-sandbox | Hire sandbox (us-west-2) |

## クォータ（2026-03 時点）

### ap-northeast-1 / us-west-2（共通）

| クォータ名 | 値 |
|---|---|
| Cross-region RPM for Haiku 4.5 | 10,000 |
| Cross-region TPM for Haiku 4.5 | 5,000,000 |
| Global cross-region TPM for Haiku 4.5 | 5,000,000 |
| Global cross-region RPM for Haiku 4.5 | 10,000 |

クォータはリージョン単位で独立（us-west-2 と ap-northeast-1 は共有しない）。

## 過去 30 日の実績（2026-03 時点）

### ap-northeast-1

| profile | 30日 invocations | ピーク TPM | 平均 TPM | ピーク RPM |
|---|---|---|---|---|
| ats-rails prod (urvozc88lce5) | 344 | 41,825 | 14,356 | 6 |
| ats-rails qa (3gmiesxoc5f3) | 288 | 173,899 | 17,861 | 39 |
| wantedly prod (f86khekcrhmm) | 1 | - | - | - |

### us-west-2

| profile | 30日 invocations | ピーク TPM | 平均 TPM | ピーク RPM |
|---|---|---|---|---|
| wantedly prod (82ye67zauvzh) | 21 | 610,014 | 60,246 | 120 |
| users-rails prod (70wricn918yo) | 1,233 | 117,219 | 10,632 | 2 |
| timeline prod (v7mn0icf72gs) | 2,354 | 335,912 | 216,748 | 91 |
| ats-rails sandbox (i4snu3l68u52) | 4,491 | 106,605 | 33,023 | 36 |

## Terraform でのプロビジョニング

`wantedly-terraform/terraform/base_modules/bedrock/main.tf` のモジュールを使用。

```hcl
module "bedrock_xxx" {
  source         = "../../base_modules/bedrock"
  primary_region = "ap-northeast-1"  # Hire の場合
  app_name       = "ats-rails"
  env            = "prod"
  models         = ["claude-haiku-4-5"]
  bedrock_regions = ["ap-northeast-1", "ap-northeast-3"]
  use_regional_inference_profile = true
}
```

新しいサービスが Bedrock を使う場合はこのモジュールで Application Inference Profile を作成し、
各 profile の CloudWatch ID を上記の一覧に追記する。

## 関連 GitHub Issues

- #15114: Hire 書類選考 AI Quota 確認（Quota 引き上げ不要と判断）
- #14456: Bedrock Quota 引き上げ申請（Claude Sonnet 4 用）
- #15325: Hire レジュメ PDF パース機能 Haiku 4.5 利用申請（Quota 引き上げ不要）
