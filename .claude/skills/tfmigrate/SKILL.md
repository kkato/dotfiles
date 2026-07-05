---
name: tfmigrate
description: Terraform stateのマイグレーション（リソース名変更、tfstate間移動、import、rm）を行うためのtfmigrateファイル作成とPR作成を支援する。リソース名変更、モジュール構造変更、既存リソースのimport、tfstate分割などの作業時に使用する。「tfmigrate」「terraform state mv」「リソース名変更」「tfstate分割」などのキーワードで発動。
---

# tfmigrate

wantedly-terraform リポジトリで Terraform state のマイグレーションを行うためのガイド。

## 概要

tfmigrate は terraform state の変更をコードとして管理するツール。CIでは tfaction 経由で実行される。

## ワークフロー

### 1. マイグレーションファイルの作成

ワーキングディレクトリの `tfmigrate/` 配下に `YYYYmmddHHMMSS_<name>.hcl` 形式で作成する。

```bash
cd terraform/<working-directory>
../../script/create-migration <name>
# 例: ../../script/create-migration mv_resource_name
```

### 2. マイグレーションファイルの記述

#### 同一 tfstate 内での変更（mv, rm, import）

```hcl
# documents
# - https://github.com/wantedly/wantedly-terraform/blob/master/docs/tfmigrate.md
# - https://suzuki-shunsuke.github.io/tfaction/docs/feature/tfmigrate/
# - https://github.com/minamijoyo/tfmigrate

migration "state" "<timestamp>_<name>" {
  dir = "."
  actions = [
    # リソース名変更
    "mv aws_s3_bucket.old_name aws_s3_bucket.new_name",

    # for_each を使用しているリソースの場合（キーにスペースや特殊文字を含む場合はシングルクォートで囲む）
    "mv 'google_project_iam_member.old[\"user@example.com roles/admin\"]' 'google_project_iam_member.new[\"user@example.com roles/admin\"]'",

    # 正規表現によるモジュール移動
    "xmv module.old_module.* module.new_module.$1",

    # 既存リソースのimport
    "import aws_s3_bucket.bucket bucket-name",

    # stateからの削除（リソース自体は削除しない）
    "rm datadog_dashboard.old",
  ]
}
```

#### tfstate 間での移動（multi_state）

```hcl
migration "multi_state" "<timestamp>_<name>" {
  from_dir = "../../monolith"  # 移行元（相対パス）
  to_dir   = "."               # 移行先

  # default_tags などで差分が出る場合
  force = true

  actions = [
    "mv aws_elasticache_cluster.old aws_elasticache_cluster.new",
  ]
}
```

### 3. Terraform ファイルの修正

マイグレーションファイルの `actions` と整合するように terraform ファイルを修正する。

- `mv`: リソース名を変更
- `import`: 新しいリソース定義を追加
- `rm`: リソース定義を削除
- `multi_state`: 移行元からリソース定義を削除し、移行先に追加

### 4. PR 作成とラベル付与

PR に以下のラベルを付与する：

- **同一 tfstate**: `tfmigrate:terraform/<path>` （例: `tfmigrate:terraform/engagement/prod`）
- **multi_state（移行先）**: `tfmigrate:terraform/<path>`
- **multi_state（移行元）**: `skip:terraform/<path>` （terraform plan/apply をスキップ）

## 注意事項

- `force = true` を設定した場合、tfmigrate apply 後に追加の terraform apply PR が必要
- tfmigrate plan で差分がある場合、tfmigrate apply はエラー終了する
- for_each キーにスペースや特殊文字を含む場合はシングルクォートで囲む

## 参考

- https://github.com/wantedly/wantedly-terraform/blob/master/docs/tfmigrate.md
- https://github.com/minamijoyo/tfmigrate
- https://suzuki-shunsuke.github.io/tfaction/docs/feature/tfmigrate/
