# Flutter プロジェクト向けハーネスエンジニアリング設計(ORBIT)

## 目的

この文書は、宇宙待ち受けアプリ ORBIT のハーネスエンジニアリング方針を定義する。

ここでいうハーネスとは、アプリ本体の外側にある再現可能な実行環境のこと。プロジェクト生成、依存解決、静的解析、テスト、端末実行、テストデータ、CI、失敗時の証跡までを含む。

ハーネスの目的は、品質確認を属人化させず、壊れたときに「どこで、なぜ、どう壊れたか」を追える状態を最初のコミットから作ること。

## 関連ドキュメント

- `docs/product-spec.md`: 今回開発する待ち受けアプリの仕様(プロトタイプ `docs/prototype/orbit_space_wallpaper_app.html` 準拠)。
- `docs/architecture.md`: Flutter アーキテクチャとフォルダ構成(レイヤー、差し替え境界の配置、依存ルール)。
- `docs/test-plan.md`: この方針を本アプリに適用した具体的なテスト計画(何をどの層で守るか、差し替え境界の具体化)。
- `docs/design-docs/`: プール方式・写真供給元・オフライン方針などの ADR。
- `CLAUDE.md`: 日常コマンドと開発規約の要約。

## このアプリ特有の事情

ORBIT は「通信しない待ち受け」を中心に据える。これがハーネス設計を仕訳ドリル系の純オフラインアプリと分ける。

- **写真はローカルプールから配る。** 起動時はプール(数十〜数百枚)からランダムに 1 枚選ぶだけで、ネットを叩かない。よって**オフライン動作が launch scope に入る**(圏外・機内モードで真っ白を避ける)。
- **通信はするが、隔離して低頻度化する。** プールの補充は前回更新から 24 時間以上経ったときだけ、起動後にバックグラウンドで行う。通信は `PhotoSource` 境界の裏に閉じ込め、デフォルトのテストは public internet に出さない。
- **画像バイナリのキャッシュ**(ファイル保存)とプールのメタデータ永続化を、テストで決定的に扱える境界として切る。

したがってハーネスは、ネットワーク・ストレージ・時間(補充間隔)・乱数(選択)を fake で制御できることを最優先にする。

## ゴール

- ローカルと CI の実行結果をできるだけ一致させる。
- 安い層のテストで先に回帰を捕まえる。
- テストデータ、アプリ設定、端末条件を明示する。
- 失敗時にログ、スクリーンショット、差分、レポートから原因を追えるようにする。
- 新しい開発者が暗黙知なしでテストを追加できるようにする。
- モバイル固有のリスク、つまり端末差分、権限、ライフサイクル、ネットワーク、ローカライズ、Platform Channel を扱えるようにする。

## 非ゴール

- プロダクト機能そのものは定義しない。
- アプリ全体の最終アーキテクチャはこの文書だけでは決めない。
- リリース戦略、監視設計、詳細なテストケース一覧の代替にはしない。

## ハーネスのレイヤー

ハーネスは次の 5 層に分けて設計する。

## 1. プロジェクトブートストラップ

クリーンチェックアウトから同じ状態を再現できるようにする層。

必要なもの:

- Flutter SDK バージョンの固定。
- Dart / Flutter の対応バージョン明記。
- 依存関係を解決するコマンド。
- 静的解析を実行するコマンド。
- デフォルトのテストを実行するコマンド。
- ローカルと CI の環境変数テンプレート。

初期コマンド候補:

```sh
flutter pub get
flutter analyze
flutter test --exclude-tags golden
```

推奨:

- Flutter SDK は FVM で固定する。
- バージョンの単一の真実は `.fvmrc`。CI(`.github/workflows/check.yml`)と `codemagic.yaml` は `flutter-version` をハードコードしているため、バージョン更新時は必ず全部を同時に変更する。片方だけ更新された状態を検知できないことが既知のリスク。
- flavor は必要になるまで増やさない。
- まずは `dev` と `test` の設定差分だけを明示する。

## 2. テスト実行ハーネス

テストをどの粒度で持ち、どのタイミングで実行するかを決める層。

テスト種別:

- Unit test: 純粋な Dart ロジック(プール選択、補充間隔判定、フォーマット、モデル変換、NASA レスポンスのパース)。
- Widget test: UI 状態、HUD の表示分岐、設定の反映、ジェスチャー、semantics。
- Golden test: 共有コンポーネントや壊れやすい画面(HUD オーバーレイ、設定シート行、コレクションセル)の視覚差分。
- Integration test: アプリ起動、プールからの 1 枚表示、設定変更、お気に入り保存を含むユーザージャーニー。
- Contract test: NASA Images API レスポンスのパース契約、プール / 設定の永続化スキーマ互換性。

初期方針:

- Pull Request では unit test と widget test を必須にする。
- UI 基盤やデザイン変更を含む PR では golden test を実行する。
- integration test は main branch、release branch、手動検証で実行する。
- 遅いテストや flaky なテストは黙って除外せず、分類して追跡する。

コマンド候補:

```sh
flutter test --exclude-tags golden
flutter test test/widget
flutter test --update-goldens --tags golden
flutter test integration_test
```

将来的には `tool/test` や `melos`、`just`、`make` などでラップしてもよい。ただし、Flutter 標準コマンドで何が起きているかは隠しすぎない。

## 3. アプリ実行時ハーネス

テスト時のアプリ状態を制御する層。

必要な能力:

- 決定的な seed data(既知の写真プール fixture)。
- ローカルストレージ(設定・お気に入り・プールメタ)のリセット。
- モック可能な通信境界(`PhotoSource`)。
- 差し替え可能な clock(補充間隔・時計)。
- 決定的な乱数(プールからの選択)。
- locale の切り替え。
- 画像キャッシュ(ファイル)のインメモリ fake。

原則:

テストは、本番の NASA API、実時間、前回の端末状態、外部サービスの気分に依存しない。依存する場合は、そのテストが明示的に end-to-end 検証であると分かる名前と配置にする。

エントリーポイント候補:

- `lib/main.dart`: 通常起動(本番境界)。
- `lib/main_dev.dart`: 開発用設定。
- `lib/main_test.dart`: integration test 用設定(fake clock・固定 seed・インメモリ store・フェイク source)。

差し替え対象の候補:

- `Clock`
- `Random`(seed 注入)
- `PhotoSource`(NASA Images API)
- `PoolStore`(プールメタデータの永続化)
- `ImageStore`(画像バイナリのファイル保存)
- `SettingsStore`(カスタマイズ設定の永続化)
- `CollectionStore`(お気に入りの永続化)

## 4. 端末・プラットフォームハーネス

モバイル固有の差分を扱う層。

対象 platform:

- Android。
- iOS。

最小端末マトリクス:

- 最新寄りの Android emulator。
- サポート下限に近い Android API level。
- 最新寄りの iOS simulator。
- 小さい画面。
- 大きい画面。

記録すべき条件:

- OS version。
- 画面サイズと pixel density(全画面の写真表示が中心なので重要)。
- locale。
- text scale。
- light / dark mode(本アプリは常時ダーク基調だが OS 設定の影響を確認する)。
- network condition(**オンライン / オフライン / 低速。プール方式の核心**)。
- app lifecycle state(バックグラウンド復帰時の補充)。

初期推奨:

CI の端末マトリクスは小さく始める。端末差分由来のバグが実際に出たら、その種類に合わせて増やす。

ネットワーク条件は明示的にテストする。**オフライン起動でプールから表示できること**、**補充失敗時に既存プールを保持すること**を端末ハーネスの確認項目に含める。

push notification・background fetch(OS のバックグラウンド実行枠)は初期 scope に含めない。補充は「起動後フォアグラウンドで非同期実行」で始め、必要になってから OS のバックグラウンド実行を検討する。

## 5. 証跡・診断ハーネス

失敗を調査可能にする層。

CI 実行で残すもの:

- machine-readable test report。
- human-readable summary。
- analyzer output。
- integration test 失敗時の screenshot。
- test 名、端末 profile、app flavor、seed、プール状態を含む log。
- golden test 失敗時の diff artifact。

integration test 失敗時に残すもの:

- 最終 screenshot。
- step log。
- device log。
- random seed または fixture version。
- 実行時の app config(プール件数・最終補充時刻など)。

## 推奨ディレクトリ構成

```text
.
├── docs/
│   └── harness-engineering.md
├── lib/
│   ├── main.dart
│   └── src/
├── test/
│   ├── unit/
│   ├── widget/
│   ├── golden/
│   └── fixtures/
├── integration_test/
├── tool/
│   ├── test_harness/
│   └── ci/
└── .github/
    └── workflows/
```

monorepo 化する場合は、各 package にスクリプトを重複させず、workspace 側に orchestration を寄せる。

## 品質ゲート

Pull Request の最低ライン:

- 依存解決が成功する。
- format check が通る。
- static analysis が通る。
- unit test と widget test が通る。
- 意図しない golden 差分が含まれていない。

main branch の推奨ライン:

- Pull Request の最低ライン。
- golden test。
- integration smoke test。
- 対象 platform の build sanity check。

release 前の推奨ライン:

- main branch の推奨ライン。
- expanded integration suite。
- 少なくとも 1 台の実機での exploratory test(オフライン起動と補充を含む)。
- accessibility smoke check。
- 複数 locale を出す場合は localization smoke check。

## Flaky Test ポリシー

flaky test はテストの問題ではなく、ハーネスの欠陥として扱う。

発生時の流れ:

1. 失敗 artifact を保存する。
2. owner を決める。
3. 原因候補を分類する。
4. 修正するか、issue link 付きで quarantine する。
5. 修正後に quarantine を解除する。

分類候補:

- app race。
- test race。
- device instability。
- network dependency(**実 NASA API に出ているテストはこれ。境界 fake に直す**)。
- timeout。
- animation(スキャンライン・フェード)。
- clock(補充間隔・時計)。
- platform behavior。

ルール:

- 理由を残さずテストを削除しない。
- 最初の対応として timeout を安易に伸ばさない。
- sleep より明示的な同期を優先する。

## テストデータと Fixture

fixture は小さく、意図が分かる形で version 管理する。

ルール:

- 読みやすさが上がる小さな fixture は test 内 inline でもよい。
- 再利用する fixture は `test/fixtures` に置く。
- endpoint 名ではなく、検証したい振る舞いで命名する(例: `nebula_pool_of_three`、`empty_pool`)。
- 本番データ snapshot は原則使わない。NASA レスポンスのパース契約テスト用に、サニタイズした小さな JSON サンプルを 1〜2 件だけ置く。
- schema 変更時は migration note を残す。

fixture に持たせたい metadata:

- schema version。
- source または generator。
- 想定する検証範囲。
- 既知の制約。

## Network Harness

通信は `PhotoSource` 境界で制御する。**通信はプール補充のときだけ発生し、表示経路では一切発生しない**ことをハーネスで担保する。

優先順位:

1. unit test では `PhotoSource` フェイク(成功・空・失敗・タイムアウトを再現)。
2. NASA レスポンスのパースは、保存した JSON サンプルに対する contract test。
3. widget / integration test では mock HTTP adapter またはフェイク source。
4. staging / 実 API は明示的な end-to-end 検証だけに使う。

デフォルトのテストスイートは、public internet や不安定な共有サービスに依存させない。**「表示経路で通信していないこと」自体もテストする**(フェイク source の呼び出し回数が 0 であることを assert する等)。

## Golden Test 方針

golden test は、安定した視覚契約を守るために使う。

visual regression とは、意図しない見た目の変化を検出すること。release blocker にするとは、golden test や visual regression test が失敗した場合にリリースを止める運用にする、という意味。

初期方針:

- launch 初期は visual regression を release blocker にしない。
- 共有 UI component と主要画面の見た目が安定してから、release blocker 化を再検討する。
- blocker にする前に、false positive の少なさ、差分確認フロー、更新責任者を決める。

向いている対象:

- 共有コンポーネント(HUD の各パーツ、設定シートの行、チップ、コレクションセル)。
- empty / loading / error state(プール空・補充中・オフライン)。
- 密度が高く崩れやすい layout。

向いていない対象:

- animation が中心の画面(スキャンライン)。
- **remote image が支配的な画面**。写真そのものは golden に含めず、ダミー画像 / 単色プレースホルダで HUD レイヤだけを検証する。
- 価値が低い全画面 snapshot。

golden test では次を固定する:

- device size。
- text scale。
- theme。
- locale。
- font loading behavior。
- **写真レイヤは固定のプレースホルダに差し替える**(remote 画像に依存しない)。

加えて、golden 画像は実行 platform のフォントレンダリングに依存する。開発機(Windows / macOS)と CI(ubuntu-latest)で生成画像が一致しない場合があるため、**基準 platform を CI と同じ Linux に固定する**(ADR 0002)。

- golden の生成・更新(`--update-goldens`)は基準 platform 上で行う。
- ローカルが基準 platform と異なる OS の場合、platform 差由来の golden 失敗を理由にローカルで golden を更新しない。
- golden test には tag `golden` を付け、非 Linux では skip、CI では専用 job で比較する。

## CI 設計

CI provider は GitHub Actions を使う。

初期 CI:

1. checkout。
2. Flutter SDK install。
3. Pub cache restore。
4. dependency resolution。
5. format check。
6. static analysis。
7. unit / widget test(machine-readable report を `test-results/` に出力する。例: `flutter test --exclude-tags golden --reporter expanded --file-reporter json:test-results/test-results.json`)。
8. 失敗 artifact upload(report を出力していないと upload 対象が空になる点に注意)。

追加候補:

- golden test job(`.github/workflows/check.yml` の `golden` job)。
- Android integration job(`.github/workflows/integration.yml`)。
- iOS integration job。
- build job。
- release candidate validation job。

CI はフィードバック速度で分割する。速い job は、遅い emulator job を待たずに結果が返るようにする。

GitHub Actions では、まず `.github/workflows/check.yml` に format、analysis、unit / widget test、golden 比較を置く。Android / iOS の emulator job は、integration smoke test を追加する段階で別 job として分離する(`integration.yml`)。

## ローカル開発体験

ローカルハーネスは次の問いにすぐ答えられる必要がある。

- この checkout は正常か。
- CI と同じチェックを走らせるには何を実行するか。
- golden を更新するには何を実行するか。
- integration test の失敗をどう再現するか。
- artifact はどこに出るか。
- app state(プール・設定・お気に入り)をどうリセットするか。

将来のコマンド候補:

```sh
tool/check
tool/test
tool/test_golden
tool/test_integration
tool/doctor
```

Windows をサポートするため、PowerShell 版を用意するか、Dart 製の cross-platform tool に寄せる。

## 初期決定事項

| Topic | 推奨 | 理由 |
| --- | --- | --- |
| Target platforms | Android と iOS | 両 platform を launch scope として扱う |
| Backend authentication | 初期 scope では不要 | NASA Images API は API キー不要。認証前提の harness を作り込まない |
| Offline support | **launch scope に入れる** | 待ち受けはオフラインで動く必要がある。プールから表示する設計の核心 |
| Network usage | **補充時のみ・境界で隔離** | 表示経路で通信させない。通信は `PhotoSource` の裏、24h に 1 回程度 |
| Image cache | ローカルファイルにキャッシュ | プールの実体。`ImageStore` 境界でテスト時はインメモリ化 |
| Locale | 単一 locale(日本語) | localization harness は過剰に作らない |
| Notification | **初期 scope に入れない** | 補充は起動後フォアグラウンドで実行。push / background fetch は後回し |
| Flutter version | FVM で固定 | ローカルと CI を揃える |
| State reset | test entry point に明示 API を置く | 端末状態への依存を避ける |
| Network test | フェイク source を基本、contract test で JSON パース | flaky と外部依存を減らす |
| Random | seed 注入で決定的に | プール選択を再現可能にする |
| Golden test | 共有 component から開始・写真は固定プレースホルダ | remote image 依存を golden に持ち込まない |
| Visual regression blocker | 初期 release blocker にはしない | UI が安定する前に blocker 化すると false positive が重い |
| Integration test | smoke journey から開始 | 起動とプール表示を早期に保証する |
| CI artifact | 失敗時に upload | remote debugging を可能にする |
| Flaky handling | issue link 付き quarantine のみ許可 | 静かな coverage loss を防ぐ |
| CI provider | GitHub Actions | repository 内の workflow として管理しやすい |
| Monorepo tool | 使わない想定 | 単一 Flutter app として始め、必要になるまで導入しない |

## 未決質問

- 補充の実行タイミングを「起動後フォアグラウンド」から OS のバックグラウンド実行枠へ広げるか(電池・OS 制約とのトレードオフ)。実 feature 要求が出た時点で ADR 化する。
- 実機での待ち受け(ロック画面壁紙)設定をアプリから行うか、写真保存にとどめるか(iOS は OS 制約が強い)。プロトタイプは保存 + OS 設定への誘導。

## 最初の実装マイルストーン

1. Flutter app skeleton を作る。
2. Flutter / Dart version を固定する。
3. baseline analysis options を追加する。
4. `test/unit` と `test/widget` を作る。
5. プール選択(`RandomPhotoPicker`)と補充判定(`RefreshPolicy`)の pure Dart ロジック + unit test を最初の green にする。
6. `PhotoSource` / `PoolStore` / `ImageStore` 境界インターフェースと fake を追加する。
7. 決定的な app config interface(`Dependencies`)を追加する。
8. format、analysis、test の CI を追加する。
9. 失敗 artifact upload を追加する。
10. integration smoke test を追加する(オフライン起動 → プールから 1 枚表示)。
11. 共有 UI primitive(HUD パーツ)ができた段階で golden test を追加する。

## レビュータイミング

この文書は次のタイミングで見直す。

- project skeleton 作成後。
- 最初の実 feature 実装後。
- プール補充を OS バックグラウンド実行へ広げる前。
- integration test を CI に入れる前。
- 初回 beta release 前。
- 同じ種類の flaky failure が繰り返された後。

ハーネスエンジニアリングはプロダクトと一緒に育てる。ただし、約束は変えない。誰でも再現でき、誰でも診断でき、チームが品質シグナルを信頼できる状態を保つ。
