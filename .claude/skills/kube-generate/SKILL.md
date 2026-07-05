---
name: kube-generate
description: wantedly のマイクロサービスリポジトリで使われる kube-generate.yaml に関する知識を Claude に読み込ませるスキル。kube-generate.yaml の構造、generator 種別（autoscale/worker/grpc/cronjob 等）、`kube generate --update` の仕組み、Pod Identity 用 ServiceAccount の追加などを扱う。「kube-generate.yaml を編集」「kube generate --update」「generator を追加」「serviceAccount を追加」「autoscale/worker/grpc/cronjob を追加」「resources を変更」などのキーワードで発動。
---

# kube-generate

wantedly のマイクロサービスリポジトリで使われる `kube-generate.yaml` に関する知識ベース。具体的な作業を機械的に実行するためのスキルではなく、kube-generate.yaml を編集・運用する際の前提知識を Claude に読み込ませるためのもの。

## 概要

- `kube-generate.yaml` はマイクロサービスの Kubernetes manifest を宣言的に記述するための入力ファイル
- CI が `kube generate --update` を実行し、`kubernetes/<env>/` 配下の deployment / cronjob / worker などの manifest を自動生成する
- CI の検証は `kube-generate.yaml` と `kubernetes/` 配下の yaml が一致しているかをチェックする仕組み
  - したがって `kube-generate.yaml` を編集したら **必ず手元で `kube generate --update` を実行してから commit & push する**
- `wantedly.com/generated-by: manual` annotation が付いた yaml は自動生成対象外（手動管理）
  - 例: `serviceaccount.yaml` など kube-generate が扱わないリソースはこの annotation を付けて手動管理する

## generator 種別

| generator | 役割 | Pod を作る（= serviceAccount 対象） | 備考 |
|-----------|------|------------------------------------|------|
| `autoscale` | web サーバー用 Deployment + HPA | ✅ | prod/qa/sandbox で別エントリに分かれていることが多い |
| `worker` | sidekiq や subscriber などの worker Deployment | ✅ | `subdir` で出力先を分けられる |
| `grpc` | gRPC サーバー | ✅ | |
| `cronjob` | バッチジョブの CronJob | ✅ | 環境ごとにエントリが分かれている場合あり |
| `namespace` | Namespace | ❌ | Pod を作らない |
| `ingress` | Ingress | ❌ | |
| `redis` | Redis 用 StatefulSet 等 | ❌ | |
| `sidekiq-exporter` | sidekiq メトリクス用 | ❌ | |

## 主要フィールド

- `clusters`: 生成対象の環境（`sandbox` / `qa` / `production`）。省略すると全環境対象
- `subdir`: 出力先ディレクトリを分ける場合に使う。同じ generator 種別が複数ある場合に活用
- `serviceAccount`: Pod Identity 用の ServiceAccount 名。Pod を作る generator にのみ指定可能
- `resources`: CPU / memory の requests/limits
- `replicas`: 初期レプリカ数
- `env`: 環境変数

## 典型作業レシピ

### 共通の流れ

1. `kube-generate.yaml` を編集
2. `kube generate --update` を実行して `kubernetes/` 配下を再生成
3. 変更された yaml を明示的に `git add` してコミット（`git add -A` は使わない）

```bash
cd ~/ghq/github.com/wantedly/<repo>
kube generate --update
git add kube-generate.yaml kubernetes/<env>/<file>.yaml
git commit -m "..."
```

### Pod Identity 用 ServiceAccount の追加

1. 各環境の `kubernetes/<env>/serviceaccount.yaml` を手動作成（自動生成対象外）

   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     annotations:
       wantedly.com/generated-by: manual
     name: <app-name>
     namespace: <namespace>
   ```

   - `wantedly.com/generated-by: manual` は必須（CI による上書き防止）
   - namespace はアプリ名と同じことが多い

2. `kube-generate.yaml` の対象 generator エントリに `serviceAccount: <name>` を追加

   ```yaml
   - autoscale:
       clusters:
       - sandbox
       serviceAccount: finder-go   # 追加
       ...
   ```

3. `kube generate --update` で再生成し、`kubernetes/<env>/deployment.yaml` 等に `serviceAccountName` が挿入されていることを確認

- 参考実例: `wantedly/miracle-search@2f51e34`, `@1fad266`, `@b771e2e`

### generator の追加 / resources の変更

- 流れは共通（kube-generate.yaml 編集 → `kube generate --update` → 差分確認 → commit）
- `kubernetes/` 配下の deployment.yaml 等を直接編集しても CI で上書きされるので、**常に kube-generate.yaml 側を編集する**

## 注意事項

- 同一 generator で prod/qa/sandbox が別エントリに分かれている場合、**すべてのエントリに同じ変更を入れる**必要がある
- `clusters` 指定なしで全環境対象になっているエントリ（例: `people-rtdn-subscriber`）も見落とさない
- `subdir` があってもフィールドの追加方法は同じ
- `kubernetes/` 配下のうち `wantedly.com/generated-by: manual` を持つ yaml だけが手動管理。それ以外は `kube-generate.yaml` が真実のソース
- 再生成を忘れてプッシュすると CI が落ちる（`kube-generate.yaml` と `kubernetes/` の不一致）
