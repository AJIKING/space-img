# ORBIT(orbit)

NASA の宇宙写真を「待ち受け」風に眺める Flutter アプリ。HUD・カスタマイズ・お気に入り・待ち受けプレビューを持つ。写真は端末ローカルのプールからランダムに 1 枚選ぶ方式で、起動時は通信しない(オフライン動作・高速起動・レートリミット回避)。プール補充は 24 時間に 1 回程度、起動後にバックグラウンドで行う。

- プロダクト仕様: `docs/product-spec.md`(プロトタイプ `docs/prototype/orbit_space_wallpaper_app.html` 準拠)
- アーキテクチャ: `docs/architecture.md`(レイヤー構成・フォルダ構成・依存ルール。コードを置く場所はここに従う)
- テスト計画: `docs/test-plan.md`(機能 × テスト層の対応表。実装時はここに従う)
- ハーネス方針: `docs/harness-engineering.md`(品質ゲート、flaky ポリシー、CI 設計の正典)
- 設計判断の記録: `docs/design-docs/`(プール方式・写真供給元・オフライン方針などの ADR)

## 環境

- Flutter SDK: **3.44.1**(`.fvmrc` で固定。CI も同バージョン)
- FVM がインストールされている環境では `fvm flutter ...` を使う。なければ `flutter` を直接使う。
- 対象プラットフォーム: Android / iOS。

## 基本コマンド

| 目的 | コマンド |
| --- | --- |
| 依存解決 | `flutter pub get` |
| フォーマットチェック | `dart format --output=none --set-exit-if-changed .` |
| フォーマット適用 | `dart format .` |
| 静的解析 | `flutter analyze` |
| 全テスト | `flutter test --exclude-tags golden --reporter expanded` |
| golden 更新 | `flutter test --update-goldens --tags golden`(基準 platform 上のみ) |

CI(`.github/workflows/check.yml`)は format → analyze → test の順で実行する。PR を出す前にローカルで同じ 3 つを通すこと(`/check` コマンドで一括実行できる)。

## テスト方針(要約)

- **TDD で進める**: 実装より先に失敗するテストを書く(red → green → refactor)。テストのない実装変更を完了として報告しない。バグ修正はまず再現テストを書いてから直す。
- 配置: unit は `test/unit/`、widget は `test/widget/`、golden は `test/golden/`、再利用 fixture は `test/fixtures/`。
- PR では unit / widget test が必須。golden は UI 基盤・デザイン変更時のみ。integration は main / release で実行。
- テストは本番アカウント・実時間・前回の端末状態・外部サービスに依存させない。`Clock`、`PhotoSource`、`PoolStore`、`ImageStore`、`SettingsStore`、`Random` は差し替え可能な境界で fake にする。
- **通信(NASA Images API)は `PhotoSource` 境界の裏に隔離する。デフォルトのテストスイートから public internet に出ない。** 補充ロジックはフェイク source で検証する。
- golden test では device size / text scale / theme / locale / font loading を固定する。golden 画像は platform 依存のため、基準 platform は CI と同じ Linux。**Windows のこの環境では platform 差由来の golden 失敗を理由に `--update-goldens` しない。** golden test はタグ `golden` 付きで、Windows では自動 skip される(ADR 0002)。

## プール方式(このアプリの肝)

- 端末に数十〜数百枚の写真をローカルにキャッシュ(プール)し、**起動時はプールからランダムに 1 枚選ぶだけ**。ここでネットを叩かない。
- プールの補充は**前回更新から 24 時間以上経過しているときだけ、起動後にバックグラウンドで**行う。判定は `Clock` + `RefreshPolicy`、取得は `PhotoSource` 境界。
- 選択の乱数は `Random(seed)` を注入(プロトタイプの `Math.random()` 直叩きは踏襲しない)。失敗再現のため seed をログに残す。
- 詳細は ADR 0001(プール方式)/ 0003(写真供給元)/ 0004(オフライン・フォールバック)。

## Flaky test ポリシー(要約)

flaky はハーネスの欠陥として扱う。**理由を残さずテストを削除しない。timeout を安易に伸ばさない。sleep より明示的な同期を使う。** quarantine する場合は必ず issue link を付ける。詳細な分類と手順は `docs/harness-engineering.md` の「Flaky Test ポリシー」を参照。

## コーディング規約

- lint は `analysis_options.yaml`(flutter_lints ベース)に従う。lint を黙らせる `// ignore:` は理由コメント必須。
- 生成ファイルや golden 画像以外で `flutter analyze` の warning を増やさない。

## Claude Code ハーネス

- スラッシュコマンド: `/check`(CI 相当のローカル検証)、`/golden`(golden の検証・更新)、`/flaky`(flaky test の triage)、`/harness-review`(差分をハーネス方針と照合)
- サブエージェント: `flutter-implementer`(機能実装。TDD と依存ルールを遵守)、`flutter-test-writer`(テスト作成)、`flaky-triager`(flaky 調査)、`harness-reviewer`(品質ゲートレビュー)
